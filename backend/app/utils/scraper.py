import aiohttp
import asyncio
import json
from bs4 import BeautifulSoup
from datetime import datetime
import os
from pathlib import Path
import logging
from typing import Dict, List, Optional, Set
from urllib.parse import urljoin, urlparse
import re
import mimetypes
import hashlib
from concurrent.futures import ThreadPoolExecutor

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class GovSiteScraper:
    def __init__(self):
        self.session = None
        self.base_save_path = Path(__file__).parent.parent / 'scraped_data'
        self.base_save_path.mkdir(exist_ok=True)
        self.visited_urls: Set[str] = set()
        self.max_depth = 2  # Maximum depth for following links
        self.download_path = self.base_save_path / 'downloads'
        self.download_path.mkdir(exist_ok=True)
        
    def _is_same_domain(self, url1: str, url2: str) -> bool:
        """Check if two URLs belong to the same domain"""
        domain1 = urlparse(url1).netloc
        domain2 = urlparse(url2).netloc
        return domain1 == domain2

    def _is_downloadable_file(self, url: str) -> bool:
        """Check if URL points to a downloadable file"""
        file_extensions = ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.txt', '.zip', '.rar', '.jpg', '.jpeg', '.png']
        return any(url.lower().endswith(ext) for ext in file_extensions)

    async def _download_file(self, url: str) -> Optional[Dict]:
        """Download a file and save it"""
        try:
            async with self.session.get(url) as response:
                if response.status != 200:
                    return None

                content_type = response.headers.get('content-type', '')
                if 'text/html' in content_type.lower():
                    return None

                # Generate filename from URL or content disposition
                filename = response.headers.get('content-disposition')
                if filename:
                    filename = re.findall("filename=(.+)", filename)[0].strip('"')
                else:
                    filename = url.split('/')[-1]
                    if not filename or '?' in filename:
                        filename = hashlib.md5(url.encode()).hexdigest()
                        ext = mimetypes.guess_extension(content_type) or '.bin'
                        filename = f"{filename}{ext}"

                file_path = self.download_path / filename
                data = await response.read()
                
                with open(file_path, 'wb') as f:
                    f.write(data)

                return {
                    'url': url,
                    'filename': filename,
                    'content_type': content_type,
                    'size': len(data),
                    'local_path': str(file_path)
                }
        except Exception as e:
            logger.error(f"Error downloading file {url}: {str(e)}")
            return None

    async def __aenter__(self):
        timeout = aiohttp.ClientTimeout(total=30)
        self.session = aiohttp.ClientSession(
            timeout=timeout,
            headers={
                'User-Agent': 'Government-Services-Bot/1.0 (Educational Purpose)',
                'Accept-Language': 'en-US,en;q=0.9'
            }
        )
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()

    def _clean_text(self, text: str) -> str:
        """Clean and normalize text content"""
        if not text:
            return ""
        # Remove extra whitespace and normalize
        return " ".join(text.split())

    async def _extract_content(self, url: str, depth: int = 0) -> Optional[Dict]:
        """Extract structured content from a government webpage"""
        if depth > self.max_depth or url in self.visited_urls:
            return None

        self.visited_urls.add(url)
        logger.info(f"Extracting content from {url} (depth: {depth})")

        try:
            async with self.session.get(url) as response:
                if response.status != 200:
                    logger.error(f"Failed to fetch {url}: Status {response.status}")
                    return None

                content_type = response.headers.get('content-type', '').lower()
                
                # If it's a downloadable file, handle it differently
                if 'text/html' not in content_type:
                    return await self._download_file(url)

                html_content = await response.text()
                soup = BeautifulSoup(html_content, 'html.parser')

                # Remove unwanted elements
                for tag in ['script', 'style', 'iframe', 'nav', 'footer']:
                    for element in soup.find_all(tag):
                        element.decompose()

                # Extract structured data
                data = {
                    'url': url,
                    'title': self._clean_text(soup.title.string) if soup.title else '',
                    'main_content': '',
                    'sections': [],
                    'headings': [],
                    'links': [],
                    'forms': [],
                    'downloads': [],
                    'images': [],
                    'tables': [],
                    'scraped_at': datetime.utcnow().isoformat(),
                }

                # Find main content
                main_content = soup.find(['main', 'article']) or soup.find('div', class_=['content', 'main-content'])
                if main_content:
                    data['main_content'] = self._clean_text(main_content.get_text())

                # Extract sections
                for section in soup.find_all(['section', 'div'], class_=['section', 'content-section']):
                    section_data = {
                        'heading': self._clean_text(section.find(['h1', 'h2', 'h3']).get_text()) if section.find(['h1', 'h2', 'h3']) else '',
                        'content': self._clean_text(section.get_text())
                    }
                    data['sections'].append(section_data)

                # Extract all headings
                for heading in soup.find_all(['h1', 'h2', 'h3']):
                    data['headings'].append(self._clean_text(heading.get_text()))

                # Extract forms
                for form in soup.find_all('form'):
                    form_data = {
                        'action': urljoin(url, form.get('action', '')),
                        'method': form.get('method', 'get'),
                        'inputs': []
                    }
                    for input_field in form.find_all(['input', 'select', 'textarea']):
                        form_data['inputs'].append({
                            'type': input_field.get('type', 'text'),
                            'name': input_field.get('name', ''),
                            'placeholder': input_field.get('placeholder', ''),
                            'required': input_field.get('required') is not None
                        })
                    data['forms'].append(form_data)

                # Extract tables
                for table in soup.find_all('table'):
                    table_data = []
                    headers = []
                    for th in table.find_all('th'):
                        headers.append(self._clean_text(th.get_text()))
                    
                    for row in table.find_all('tr'):
                        row_data = []
                        for td in row.find_all('td'):
                            row_data.append(self._clean_text(td.get_text()))
                        if row_data:
                            table_data.append(row_data)
                    
                    data['tables'].append({
                        'headers': headers,
                        'rows': table_data
                    })

                # Extract images
                for img in soup.find_all('img', src=True):
                    src = img.get('src')
                    if src:
                        full_url = urljoin(url, src)
                        data['images'].append({
                            'url': full_url,
                            'alt': img.get('alt', ''),
                            'title': img.get('title', '')
                        })

                # Extract links and downloadable files
                for link in soup.find_all('a', href=True):
                    href = link.get('href')
                    if href and not href.startswith(('#', 'javascript:')):
                        full_url = urljoin(url, href)
                        link_data = {
                            'text': self._clean_text(link.get_text()),
                            'url': full_url
                        }
                        
                        if self._is_downloadable_file(full_url):
                            data['downloads'].append(link_data)
                        else:
                            data['links'].append(link_data)
                            
                            # Recursively fetch content from same-domain links
                            if depth < self.max_depth and self._is_same_domain(url, full_url):
                                sub_content = await self._extract_content(full_url, depth + 1)
                                if sub_content:
                                    link_data['content'] = sub_content

                return data

        except Exception as e:
            logger.error(f"Error extracting content from {url}: {str(e)}")
            return None

    def _generate_filename(self, url: str) -> str:
        """Generate a filename from URL"""
        parsed = urlparse(url)
        filename = parsed.netloc.replace('.', '_') + parsed.path.replace('/', '_')
        if not filename.endswith('.json'):
            filename += '.json'
        return filename

    async def scrape_and_save(self, url: str):
        """Scrape a government website and save its content"""
        logger.info(f"Scraping {url}")
        content = await self._extract_content(url)
        
        if content:
            filename = self._generate_filename(url)
            filepath = self.base_save_path / filename
            
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(content, f, ensure_ascii=False, indent=2)
            
            logger.info(f"Saved content to {filepath}")
            return filepath
        return None

async def main():
    gov_urls = [
        "https://dmt.gov.lk/index.php?lang=en",
        "https://www.gov.lk/services/erl/es/erl/view/index.action",
        "https://www.transport.gov.lk/web/index.php?option=com_content&view=article&id=26&Itemid=146&lang=en",
    ]
    
    async with GovSiteScraper() as scraper:
        tasks = [scraper.scrape_and_save(url) for url in gov_urls]
        await asyncio.gather(*tasks)

if __name__ == "__main__":
    asyncio.run(main())
