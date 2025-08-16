import json
from fastapi import APIRouter, HTTPException
from typing import List
from pydantic import BaseModel
import logging
import google.generativeai as genai
from app.services.knowledge_base import KnowledgeBaseService
import os
from app.core.config import settings
from app.services.citizen.citizen_service import  get_form_template
from app.schemas.citizen import citizen_schema
from fastapi import APIRouter, HTTPException, Depends
from app.core.auth import get_current_user
from app.services.message_log import log_message
from app.services.chatbot_services import search_Answer, update_trigger, answer_search_secured, answer_search_for_help, services_get_latest_messages, services_get_latest_message_by_id 
from prisma import Prisma

db = Prisma()

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
    return await search_Answer(query)  
    
@router.post("/update")
async def trigger_knowledge_update(): # type: ignore
    """Trigger knowledge base update from government sources"""
    return await update_trigger()
    

@router.post("/search_secured")
async def search_government_services_secured(query: SearchQuery,current_user: citizen_schema.Citizen = Depends(get_current_user)):
    """Search government services using natural language"""
    return await answer_search_secured(query, current_user)
    
@router.post("/search_for_help")
async def search_government_services_for_help(query: SearchQueryForHelp):
    """Search government services using natural language"""
    return await answer_search_for_help(query)
    
@router.get("/latest-messages")
async def get_latest_messages():
    return await services_get_latest_messages()
    
@router.get("/latest-messages/me")
async def get_latest_messages_for_user(current_user: citizen_schema.Citizen = Depends(get_current_user)):
    return await services_get_latest_message_by_id(current_user)
