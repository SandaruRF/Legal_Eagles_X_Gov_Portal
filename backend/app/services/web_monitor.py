import hashlib
import asyncio
import aiohttp
from typing import Dict, List, Optional, Tuple
from datetime import datetime
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
import logging
from dataclasses import dataclass

from app.core.config import get_settings
from app.db.repositories.web_monitor import WebMonitorRepository
from app.services.knowledge_base import KnowledgeBaseService

logger = logging.getLogger(__name__)

@dataclass
class ContentChange:
    url: str
    old_hash: str
    new_hash: str
    content: str
    timestamp: datetime
    change_type: str  # 'new', 'updated', 'deleted'

class GovernmentWebMonitor:
    def __init__(self):
        self.settings = get_settings()
        self.known_hashes = {}
        self.repo = WebMonitorRepository()
        self.kb_service = KnowledgeBaseService()
        self.session = None
        
    async def __aenter__(self):
        """Async context manager entry"""
        await self.repo.connect()
        connector = aiohttp.TCPConnector(limit=self.settings.MAX_CONCURRENT_SCRAPES)
        timeout = aiohttp.ClientTimeout(total=30)
        self.session = aiohttp.ClientSession(
            connector=connector,
            timeout=timeout,
            headers={
                'User-Agent': 'Government-Services-Bot/1.0 (Educational Purpose)'
            }
        )
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit"""
        if self.session:
            await self.session.close()
        await self.repo.disconnect() 
    
    async def extract_content(self, url: str) -> Optional[str]:
        """Extract clean text content from government webpage"""
        try:
            async with self.session.get(url) as response:
                if response.status != 200:
                    logger.warning(f"Failed to fetch {url}: HTTP {response.status}")
                    return None
                
                html_content = await response.text()
                soup = BeautifulSoup(html_content, 'html.parser')
                
                # Remove unwanted elements
                unwanted_tags = [
                    'nav', 'footer', 'aside', 'script', 'style', 
                    'header', 'menu', 'advertisement', 'sidebar'
                ]
                
                for tag in soup(unwanted_tags):
                    tag.decompose()
                
                # Remove elements by class/id that are typically navigation or ads
                unwanted_selectors = [
                    '.nav', '.navigation', '.sidebar', '.advertisement',
                    '.footer', '.header', '#navigation', '#sidebar'
                ]
                
                for selector in unwanted_selectors:
                    for element in soup.select(selector):
                        element.decompose()
                
                # Extract main content areas
                main_content_selectors = [
                    'main', '.main-content', '.content', 'article',
                    '.main', '#main', '#content', '.page-content'
                ]
                
                main_content = None
                for selector in main_content_selectors:
                    main_content = soup.select_one(selector)
                    if main_content:
                        break
                
                # If no main content area found, use body
                if not main_content:
                    main_content = soup.find('body')
                
                if main_content:
                    # Extract text and clean it
                    content = main_content.get_text(separator=' ', strip=True)
                    # Remove extra whitespace
                    content = ' '.join(content.split())
                    return content
                
                return None
                
        except Exception as e:
            logger.error(f"Error extracting content from {url}: {str(e)}")
            return None
    
    def generate_content_hash(self, content: str) -> str:
        """Generate SHA-256 hash for content change detection"""
        if not content:
            return ""
        
        # Normalize content for consistent hashing
        normalized_content = content.strip().lower()
        return hashlib.sha256(normalized_content.encode('utf-8')).hexdigest()
    
    async def check_url_for_changes(self, url: str) -> Optional[ContentChange]:
        """Check specific URL for content changes"""
        logger.info(f"Checking URL for changes: {url}")
        
        try:
            # Get current content
            current_content = await self.extract_content(url)
            if not current_content:
                logger.warning(f"No content extracted from {url}")
                return None
            
            current_hash = self.generate_content_hash(current_content)
            
            # Get stored hash from database
            stored_record = await self.repo.get_url_record(url)
            
            if not stored_record:
                # New URL - store and mark as new
                await self.repo.store_url_hash(url, current_hash, current_content)
                logger.info(f"New URL detected: {url}")
                
                return ContentChange(
                    url=url,
                    old_hash="",
                    new_hash=current_hash,
                    content=current_content,
                    timestamp=datetime.utcnow(),
                    change_type="new"
                )
            
            stored_hash = stored_record.content_hash
            
            if stored_hash != current_hash:
                # Content changed
                await self.repo.update_url_hash(url, current_hash, current_content)
                logger.info(f"Content changed for URL: {url}")
                
                try:
                    await self.kb_service.store_webpage_content(
                        url=url,
                        content=current_content,
                        timestamp=datetime.utcnow()
                    )
                    logger.info(f"Updated knowledge base for changed content: {url}")
                except Exception as e:
                    logger.warning(f"Failed to update knowledge base for {url}: {str(e)}")
                
                logger.info(f"Content changed for URL: {url}")
                
                return ContentChange(
                    url=url,
                    old_hash=stored_hash,
                    new_hash=current_hash,
                    content=current_content,
                    timestamp=datetime.utcnow(),
                    change_type="updated"
                )
            
            logger.debug(f"No changes detected for: {url}")
            return None
            
        except Exception as e:
            logger.error(f"Error checking URL {url}: {str(e)}")
            return None
    
    async def monitor_government_sources(self) -> List[ContentChange]:
        """Monitor all configured government sources"""
        logger.info("Starting government sources monitoring")
        changes = []
        
        # Flatten all URLs from different categories
        all_urls = []
        for category, urls in self.settings.GOVERNMENT_SOURCES.items():
            all_urls.extend(urls)
        
        # Create semaphore to limit concurrent requests
        semaphore = asyncio.Semaphore(self.settings.MAX_CONCURRENT_SCRAPES)
        
        async def check_url_with_semaphore(url):
            async with semaphore:
                return await self.check_url_for_changes(url)
        
        # Check all URLs concurrently with limit
        tasks = [check_url_with_semaphore(url) for url in all_urls]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Filter out None results and exceptions
        for result in results:
            if isinstance(result, ContentChange):
                changes.append(result)
            elif isinstance(result, Exception):
                logger.error(f"Error in concurrent URL check: {str(result)}")
        
        # Use DocumentProcessor batch processing instead of direct ChromaDB updates
        if changes:
            try:
                # Import DocumentProcessor here to avoid circular imports
                from app.services.document_processor import DocumentProcessor
                
                processor = DocumentProcessor()
                await processor.process_multiple_changes(changes)  # Batch processing
                logger.info(f"Batch processed {len(changes)} changes through DocumentProcessor")
                
            except Exception as e:
                logger.error(f"Failed batch processing, falling back to individual processing: {str(e)}")
                
                # Fallback to individual processing
                try:
                    from app.services.document_processor import DocumentProcessor
                    processor = DocumentProcessor()
                    
                    successful_individual = 0
                    for change in changes:
                        try:
                            await processor.process_content_change(change)
                            successful_individual += 1
                        except Exception as individual_error:
                            logger.error(f"Failed to process individual change {change.url}: {str(individual_error)}")
                    
                    logger.info(f"Individual fallback completed: {successful_individual}/{len(changes)} changes processed")
                    
                except Exception as fallback_error:
                    logger.error(f"Both batch and individual processing failed: {str(fallback_error)}")
        else:
            logger.info("No changes detected during monitoring")
        
        logger.info(f"Monitoring completed. Found {len(changes)} changes.")
        return changes

    
    async def discover_additional_pages(self, base_url: str) -> List[str]:
        """Discover additional relevant pages from government site"""
        discovered_urls = set()
        
        try:
            async with self.session.get(base_url) as response:
                if response.status != 200:
                    return list(discovered_urls)
                
                html_content = await response.text()
                soup = BeautifulSoup(html_content, 'html.parser')
                
                # Find all links
                links = soup.find_all('a', href=True)
                base_domain = urlparse(base_url).netloc
                
                for link in links:
                    href = link['href']
                    full_url = urljoin(base_url, href)
                    parsed_url = urlparse(full_url)
                    
                    # Only include same domain links
                    if parsed_url.netloc == base_domain:
                        discovered_urls.add(full_url)
                
                return list(discovered_urls)[:50]  # Limit to 50 URLs per domain
                
        except Exception as e:
            logger.error(f"Error discovering pages from {base_url}: {str(e)}")
            return []
