from supabase import create_client, Client

def get_supabase_client() -> Client:
    # Replace these with your actual Supabase URL and API key
    SUPABASE_URL = "https://your-supabase-url.supabase.co"
    SUPABASE_KEY = "your-supabase-api-key"

    return create_client(SUPABASE_URL, SUPABASE_KEY)
