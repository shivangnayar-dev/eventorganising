"""
Verification service
"""
from typing import Optional, Dict, Any, List
from datetime import datetime
from app.services.service_service import ServiceService
from app.models.verification import VerificationAssignment, VerificationStatus
from app.models.service_listing import ServiceListing
from app.middleware.error_handler import HttpError


class VerificationService:
    """Verification operations"""
    
    @staticmethod
    async def get_assignments(provider_id: str):
        """Get verification assignments for a provider"""
        return await ServiceService.list_assignments(provider_id)
    
    @staticmethod
    async def get_service_assignments_for_nodal_officer(service_id: str, nodal_officer_id: str):
        """Get verification assignments for a service that the nodal officer is assigned to"""
        # Verify service is assigned to this nodal officer
        service = await ServiceListing.get(service_id)
        if not service:
            raise HttpError(404, "Service not found")
        
        if service.assigned_nodal_officer_id != nodal_officer_id:
            raise HttpError(403, "Service is not assigned to this nodal officer")
        
        # Get all assignments for this service
        assignments = await VerificationAssignment.find(
            {"serviceId": service_id}
        ).to_list()
        
        return assignments
    
    @staticmethod
    async def submit_checkpoint_responses(
        assignment_id: str,
        nodal_officer_id: str,
        checkpoint_responses: Dict[str, Any],
        images: Optional[List[str]] = None,
        videos: Optional[List[str]] = None,
        overall_rating: Optional[float] = None,
        notes: Optional[str] = None,
    ):
        """Submit checkpoint responses for a verification assignment"""
        assignment = await VerificationAssignment.get(assignment_id)
        if not assignment:
            raise HttpError(404, "Assignment not found")
        
        # Verify the service is assigned to this nodal officer
        service = await ServiceListing.get(assignment.service_id)
        if not service:
            raise HttpError(404, "Service not found")
        
        if service.assigned_nodal_officer_id != nodal_officer_id:
            raise HttpError(403, "Service is not assigned to this nodal officer")
        
        # Update assignment with checkpoint responses
        assignment.checkpoint_responses = checkpoint_responses
        if images is not None:
            assignment.images = images
        if videos is not None:
            assignment.videos = videos
        if overall_rating is not None:
            assignment.overall_rating = overall_rating
        if notes is not None:
            assignment.notes = notes
        
        assignment.submitted_at = datetime.utcnow()
        assignment.updated_at = datetime.utcnow()
        
        await assignment.save()
        
        return assignment
    
    @staticmethod
    async def verify(
        assignment_id: str,
        decision: str,
        notes: str = None,
    ):
        """Verify a service assignment"""
        status_map = {
            "APPROVED": VerificationStatus.APPROVED,
            "REJECTED": VerificationStatus.REJECTED,
            "INFO_REQUESTED": VerificationStatus.INFO_REQUESTED,
        }
        decision_status = status_map.get(decision)
        if not decision_status:
            raise ValueError(f"Invalid decision: {decision}")
        
        await ServiceService.verify_service(assignment_id, decision_status, notes)

