"""
Verification routes
"""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
from app.middleware.auth_middleware import get_current_user
from app.services.verification_service import VerificationService

router = APIRouter()


# Request models
class VerifyRequest(BaseModel):
    assignmentId: str
    decision: str  # "APPROVED", "REJECTED", "INFO_REQUESTED"
    notes: Optional[str] = None


class SubmitCheckpointResponsesRequest(BaseModel):
    assignmentId: str
    checkpointResponses: Dict[str, Any]
    images: Optional[List[str]] = None
    videos: Optional[List[str]] = None
    overallRating: Optional[float] = None
    notes: Optional[str] = None


# Routes
@router.get("/assigned")
async def get_assignments(user: dict = Depends(get_current_user)):
    """Get verification assignments for a provider"""
    assignments = await VerificationService.get_assignments(user["id"])
    return [a.dict() for a in assignments]


@router.get("/service/{service_id}/assignments")
async def get_service_assignments(
    service_id: str,
    user: dict = Depends(get_current_user),
):
    """Get verification assignments for a service (for nodal officers)"""
    user_roles = user.get("roles", [])
    is_nodal_officer = "NODAL_OFFICER" in user_roles
    
    if not is_nodal_officer:
        raise HTTPException(status_code=403, detail="Only nodal officers can access service assignments")
    
    assignments = await VerificationService.get_service_assignments_for_nodal_officer(
        service_id, user["id"]
    )
    return [a.dict() for a in assignments]


@router.post("/submit-checkpoints")
async def submit_checkpoint_responses(
    data: SubmitCheckpointResponsesRequest,
    user: dict = Depends(get_current_user),
):
    """Submit checkpoint responses for a verification assignment (for nodal officers)"""
    user_roles = user.get("roles", [])
    is_nodal_officer = "NODAL_OFFICER" in user_roles
    
    if not is_nodal_officer:
        raise HTTPException(status_code=403, detail="Only nodal officers can submit checkpoint responses")
    
    assignment = await VerificationService.submit_checkpoint_responses(
        assignment_id=data.assignmentId,
        nodal_officer_id=user["id"],
        checkpoint_responses=data.checkpointResponses,
        images=data.images,
        videos=data.videos,
        overall_rating=data.overallRating,
        notes=data.notes,
    )
    
    return {"message": "Checkpoint responses submitted successfully", "assignment": assignment.dict()}


@router.post("/verify")
async def verify(
    data: VerifyRequest,
    user: dict = Depends(get_current_user),
):
    """Verify a service assignment"""
    await VerificationService.verify(data.assignmentId, data.decision, data.notes)
    return {"message": "Verification updated"}
