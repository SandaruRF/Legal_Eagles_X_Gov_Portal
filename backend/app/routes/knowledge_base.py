from fastapi import APIRouter, HTTPException
from typing import List
from pydantic import BaseModel
import logging
import google.generativeai as genai
from app.services.knowledge_base import KnowledgeBaseService
import os
from app.core.config import settings

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/knowledge-base",
    tags=["Knowledge Base"]
)

class SearchQuery(BaseModel):
    text: str
    limit: int = 5

class SearchQueryForHelp(BaseModel):
    text: str
    page: str
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
        system_features = ["driving license medical form filling"]
        about="""This application provides information about government services, procedures, and related topics. It aims to assist users in finding relevant information quickly and efficiently."""
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
        prompt += """Based on the above, You are a helpful and respectful government service information assistant. Your job is to answer user queries about government services, procedures, and information in a clear, polite, and professional manner.
        system features : {system_features}
        about system : {about}

Always:
- Address the user respectfully.
- Provide accurate and concise information.
- Format your response with headings, bullet points, and clear sections for readability.
- If possible, include links or references to official sources but do it only if system not have that facility.

Please provide a well-formatted, easy-to-read answer to the user's query. """

        # Call Gemini
        print("Gemini API Key:", settings.GEMINI_API_KEY)
        genai.configure(api_key=settings.GEMINI_API_KEY)
        # print(list(genai.list_models()))
        model = genai.GenerativeModel("models/gemini-1.5-pro-latest")
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

@router.post("/search_for_help")
async def search_government_services_for_help(query: SearchQueryForHelp):
    """Search government services using natural language"""
    try:
        page_info={
            "home" : "this page contains a chatbot. press on text box at top to use chatbot.\n this page contains profile view option at the right top of the screen",
            "driving_license" : "press arrow icon to send to chatbot"
        }
        kb_service = KnowledgeBaseService()
        results = await kb_service.search(query.text, query.limit)
        system_features = ["driving license medical form filling","passport application filling"]
        about="""This application provides information about government services, procedures, and related topics. It aims to assist users in finding relevant information quickly and efficiently."""
        print("current page: ", query.page)
        current=page_info[query.page]
        print("current page info : ",current)
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
        prompt = f"""You are a helpful and respectful assistant of {query.page} page of a government service information system. user is currently on your page and ask for details. Your job is to answer user queries about page`s content , government services, procedures, and information in a clear, polite, and professional manner.
        {query.page} page content using instructions : {current}.
        system features : {system_features}
        about system : {about}
        user asked this : {query.text}

Always:
- dont use Relevant government services contents if user ask for page content directly. if user ask for page content just answer using page content.
- Address the user respectfully.
- answer simply as possible. dont explain anything.
- Provide accurate and concise information.
- Format your response with headings, bullet points, and clear sections for readability.
- If possible, include links or references to official sources but do it only if system not have that facility.
- Please provide a well-formatted, easy-to-read answer to the user's query. 
- Relevant government services: {search_results}.
"""

        # Call Gemini
        print("Gemini API Key:", settings.GEMINI_API_KEY)
        genai.configure(api_key=settings.GEMINI_API_KEY)
        # print(list(genai.list_models()))
        model = genai.GenerativeModel("models/gemini-1.5-pro-latest")
        gemini_response = model.generate_content(prompt)
        final_response = gemini_response.text if hasattr(gemini_response, "text") else str(gemini_response)
        
        return final_response
    
    except Exception as e:
        logger.error(f"Error in knowledge base search: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")