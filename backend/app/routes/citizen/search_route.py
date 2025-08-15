from fastapi import APIRouter, Query
from typing import List
from rapidfuzz import process


router = APIRouter(
    prefix="/search",
    tags=["Search"]
)

COMPONENTS = [
{"name": "Public Security Ministry", "route": "/ministry_public_security"},
{"name": "Transport Ministry", "route": "/ministry_transport"},
{"name": "National Transport Medical Institute", "route": "/national_transport_medical_institute"},
{"name": "Driving License Medical", "route": "/driving_license_medical_appointment"},
{"name": "Immigration Emigration Ministry", "route": "/immigration_emigration"},
{"name": "Notifications", "route": "/notifications"},
{"name": "Digital Vault", "route": "/digital_vault"},
{"name": "My Bookings", "route": "/my_bookings"},
{"name": "Past Bookings", "route": "/past_bookings"},
{"name": "Change Password", "route": "/change_password"},
{"name": "Language Settings", "route": "/language_settings"},
{"name": "Chat bot", "route": "/chat_interface"}
]

@router.get("/search-bar")
def search(q: str = Query(..., min_length=1)) -> List[dict]:
    choices = [comp["name"] for comp in COMPONENTS]
    # Get top 5 matches with score > 60
    matches = process.extract(q, choices, limit=5, score_cutoff=60)
    results = [COMPONENTS[idx] for name, score, idx in matches]
    return results
