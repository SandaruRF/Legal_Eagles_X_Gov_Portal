import os
from supabase import create_client, Client
from app.core.config import settings

# Initialize the Supabase client
url: str = settings.SUPABASE_URL
key: str = settings.SUPABASE_KEY
supabase: Client = create_client(url, key)

def get_supabase_client() -> Client:
    """
    Returns the global Supabase client instance.
    """
    return supabase
