from fastapi import APIRouter, HTTPException
from typing import List
from pydantic import BaseModel
import logging
import google.generativeai as genai
from app.services.knowledge_base import KnowledgeBaseService

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/knowledge-base",
    tags=["Knowledge Base"]
)

class SearchQuery(BaseModel):
    text: str
    limit: int = 5

class SearchQueryForm(BaseModel):
    text: str
    form: str
    limit: int = 5

class SearchResult(BaseModel):
    content: str
    source: str
    relevance_score: float
    title: str = ""

class SearchResponse(BaseModel):
    query: str
    results: List[SearchResult]
    total_results: int

@router.post("/search")
async def search_government_services(query: SearchQuery):
    """Search government services using natural language"""
    try:
        kb_service = KnowledgeBaseService()
        results = await kb_service.search(query.text, query.limit)
        
        # Convert ChromaDB results to API response
        search_results = []
        
        if results['documents'] and results['documents'][0]:
            for doc, metadata, distance in zip(
                results['documents'][0],
                results['metadatas'][0], 
                results['distances'][0]
            ):
                search_results.append(SearchResult(
                    content=doc[:500] + "..." if len(doc) > 500 else doc,
                    source=metadata.get('url', 'Unknown'),
                    title=metadata.get('title', 'Government Service'),
                    relevance_score=max(0.0, 1.0 - distance)  # Convert distance to similarity
                ))
        
        # send query.txt and search results to gemini and get final response
        prompt = f"User query: {query.text}\n\nRelevant government services:\n"
        for idx, result in enumerate(search_results, 1):
            prompt += f"{idx}. Title: {result.title}\n   Source: {result.source}\n   Content: {result.content}\n\n"
        prompt += "Based on the above, provide a helpful answer to the user's query."

        # Call Gemini
        genai.configure(api_key="AIzaSyDmc7spscGG_Fo2nxzdU0MxMNG3P2jVx9o")
        model = genai.GenerativeModel("gemini-pro")
        gemini_response = model.generate_content(prompt)
        final_response = gemini_response.text if hasattr(gemini_response, "text") else str(gemini_response)
        
        return final_response
    
    except Exception as e:
        logger.error(f"Error in knowledge base search: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")

@router.post("/update")
async def trigger_knowledge_update():
    """Trigger knowledge base update from government sources"""
    try:
        # This could trigger the web monitoring task
        from app.tasks.web_monitoring import monitor_websites_task
        task_result = monitor_websites_task.delay()
        
        return {
            "status": "Knowledge base update triggered",
            "task_id": task_result.id,
            "message": "Update will process in background"
        }
    except Exception as e:
        return {
            "status": "Update trigger failed",
            "message": f"Error: {str(e)}"
        }

@router.post("/search_forms")
async def search_government_services_(query: SearchQueryForm):
    """Search government services using natural language"""
    try:
        kb_service = KnowledgeBaseService()
        results = await kb_service.search(query.text, query.limit)
        
        # Convert ChromaDB results to API response
        search_results = []
        
        if results['documents'] and results['documents'][0]:
            for doc, metadata, distance in zip(
                results['documents'][0],
                results['metadatas'][0], 
                results['distances'][0]
            ):
                search_results.append(SearchResult(
                    content=doc[:500] + "..." if len(doc) > 500 else doc,
                    source=metadata.get('url', 'Unknown'),
                    title=metadata.get('title', 'Government Service'),
                    relevance_score=max(0.0, 1.0 - distance)  # Convert distance to similarity
                ))
        
        # send query.txt and search results to gemini and get final response
        prompt = f"User query: {query.text}\n\nRelevant government services:\n"
        for idx, result in enumerate(search_results, 1):
            prompt += f"{idx}. Title: {result.title}\n   Source: {result.source}\n   Content: {result.content}\n\n"
        prompt += "Based on the above, provide a helpful answer to the user's query."

        # Call Gemini
        genai.configure(api_key="AIzaSyDmc7spscGG_Fo2nxzdU0MxMNG3P2jVx9o")
        model = genai.GenerativeModel("gemini-pro")
        gemini_response = model.generate_content(prompt)
        final_response = gemini_response.text if hasattr(gemini_response, "text") else str(gemini_response)
        
        return final_response
    
    except Exception as e:
        logger.error(f"Error in knowledge base search: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")