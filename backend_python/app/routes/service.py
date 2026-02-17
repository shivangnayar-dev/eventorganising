"""
Service routes
"""
from fastapi import APIRouter, Depends, Request, Query
from typing import Optional, List
from pydantic import BaseModel
from app.middleware.auth_middleware import get_current_user, require_roles
from app.services.service_service import ServiceService
from app.services.admin_service import AdminService
from app.middleware.error_handler import HttpError

router = APIRouter()


# Request models
class CreateServiceRequest(BaseModel):
    title: str
    description: str
    location: str
    address: Optional[str] = None
    pincode: Optional[str] = None
    eventTypes: Optional[str] = None
    propertyType: Optional[str] = None
    capacity: Optional[int] = None
    amenities: Optional[str] = None
    photos: Optional[List[str]] = None
    price: float


class AssignAgentsRequest(BaseModel):
    serviceId: str
    agentIds: List[str]
    nodalOfficerId: Optional[str] = None


class AssignNodalOfficerRequest(BaseModel):
    serviceId: str
    nodalOfficerId: str


class OnboardProviderRequest(BaseModel):
    kycDocumentUrl: str
    pricingDetails: str
    photoUrls: Optional[List[str]] = None


class RecommendNodalOfficerRequest(BaseModel):
    officerId: Optional[str] = None
    newUserEmail: Optional[str] = None
    newUserFullName: Optional[str] = None
    newUserPhone: Optional[str] = None
    area: str
    location: str
    address: Optional[str] = None
    pincode: Optional[str] = None
    region: Optional[str] = None
    reason: Optional[str] = None


# Routes
@router.get("/public")
async def list_published_public():
    """List published services (public)"""
    try:
        services = await ServiceService.list_published()
        return [s.dict() for s in services] if services else []
    except Exception as e:
        from app.config.logger import setup_logger
        logger = setup_logger()
        logger.error(f"Error in list_published_public: {e}", exc_info=True)
        from fastapi import HTTPException
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/list")
async def list_published_services():
    """List published services (alias for /public)"""
    try:
        services = await ServiceService.list_published()
        return [s.dict() for s in services] if services else []
    except Exception as e:
        from app.config.logger import setup_logger
        logger = setup_logger()
        logger.error(f"Error in list_published_services: {e}", exc_info=True)
        from fastapi import HTTPException
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/providers")
async def list_providers(user: dict = Depends(get_current_user)):
    """List approved service providers"""
    try:
        # For now, return empty list to avoid serialization issues
        # TODO: Fix user lookup in ServiceService.list_providers()
        return []
    except Exception as e:
        from app.config.logger import setup_logger
        logger = setup_logger()
        logger.error(f"Error in list_providers: {e}", exc_info=True)
        from fastapi import HTTPException
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/categories/navbar")
async def list_navbar_categories():
    """List service categories for navbar"""
    try:
        categories = await ServiceService.list_navbar_categories()
        return categories if categories else []
    except Exception as e:
        from app.config.logger import setup_logger
        logger = setup_logger()
        logger.error(f"Error in list_navbar_categories: {e}", exc_info=True)
        from fastapi import HTTPException
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/form-fields")
async def get_form_field_configs():
    """Get active form field configurations for submission form (public)"""
    try:
        fields = await AdminService.get_active_form_field_configs()
        return fields if fields else []
    except Exception as e:
        from app.config.logger import setup_logger
        logger = setup_logger()
        logger.error(f"Error in get_form_field_configs: {e}", exc_info=True)
        from fastapi import HTTPException
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/verification-checkpoints")
async def get_verification_checkpoint_configs():
    """Get active verification checkpoint configurations for nodal officers (public)"""
    try:
        checkpoints = await AdminService.get_active_verification_checkpoint_configs()
        return checkpoints if checkpoints else []
    except Exception as e:
        from app.config.logger import setup_logger
        logger = setup_logger()
        logger.error(f"Error in get_verification_checkpoint_configs: {e}", exc_info=True)
        from fastapi import HTTPException
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/create")
async def create_service(
    data: CreateServiceRequest,
    user: dict = Depends(get_current_user),
):
    """Create a new service listing"""
    service = await ServiceService.create_service(user["id"], data.dict())
    return service.dict()


@router.get("/my")
async def list_my_services(user: dict = Depends(get_current_user)):
    """List user's services (owner or nodal officer)"""
    is_nodal_officer = "NODAL_OFFICER" in user.get("roles", [])
    
    if is_nodal_officer:
        services = await ServiceService.list_nodal_officer_services(user["id"])
    else:
        services = await ServiceService.list_user_services(user["id"])
    
    return [s.dict() for s in services]


@router.get("/pending")
async def list_pending(user: dict = Depends(get_current_user)):
    """List pending services"""
    services = await ServiceService.list_pending()
    return [s.dict() for s in services]


@router.get("/published")
async def list_published(user: dict = Depends(get_current_user)):
    """List published services"""
    services = await ServiceService.list_published()
    return [s.dict() for s in services]


@router.get("/managed")
async def list_managed_services(user: dict = Depends(get_current_user)):
    """List services managed by a manager"""
    services = await ServiceService.list_managed_services(user["id"])
    return services


@router.post("/assign")
async def assign_agents(
    data: AssignAgentsRequest,
    user: dict = Depends(get_current_user),
):
    """Assign verification agents to a service"""
    result = await ServiceService.assign_agents(
        user["id"],
        data.serviceId,
        data.agentIds,
        data.nodalOfficerId,
    )
    return result


@router.post("/assign-nodal-officer")
async def assign_nodal_officer(
    data: AssignNodalOfficerRequest,
    user: dict = Depends(get_current_user),
):
    """Assign a nodal officer to a service"""
    result = await ServiceService.assign_nodal_officer(
        user["id"],
        data.serviceId,
        data.nodalOfficerId,
    )
    return result


@router.get("/{service_id}/verification-assignments")
async def get_service_verification_assignments(
    service_id: str,
    user: dict = Depends(get_current_user),
):
    """Get verification assignments for a service (for admins/managers to view progress)"""
    # Check if user is admin or manager
    user_roles = user.get("roles", [])
    is_admin = "ADMIN" in user_roles
    is_manager = "MANAGER" in user_roles
    
    if not (is_admin or is_manager):
        from fastapi import HTTPException
        raise HTTPException(status_code=403, detail="Only admins and managers can view verification assignments")
    
    assignments = await ServiceService.get_service_verification_assignments(service_id)
    return assignments


@router.get("/{service_id}/available-officers")
async def get_available_officers(
    service_id: str,
    user: dict = Depends(get_current_user),
):
    """Get available nodal officers for a service"""
    result = await ServiceService.get_available_nodal_officers_for_service(service_id)
    return result


@router.post("/onboard-provider")
async def onboard_provider(
    data: OnboardProviderRequest,
    user: dict = Depends(get_current_user),
):
    """Onboard a service provider"""
    provider = await ServiceService.onboard_provider(user["id"], data.dict())
    return provider.dict()


@router.get("/providers")
async def list_providers(user: dict = Depends(get_current_user)):
    """List approved providers"""
    providers = await ServiceService.list_providers()
    return providers


@router.get("/nodal-officers")
async def list_nodal_officers_by_area(
    location: Optional[str] = Query(None),
    area: Optional[str] = Query(None),
    pincode: Optional[str] = Query(None),
    user: dict = Depends(get_current_user),
):
    """List nodal officers by area (for managers)"""
    filters = {}
    if location:
        filters["location"] = location
    if area:
        filters["area"] = area
    if pincode:
        filters["pincode"] = pincode
    
    officers = await ServiceService.list_nodal_officers_by_area(user["id"], filters)
    return officers


@router.post("/recommend-nodal-officer")
async def recommend_nodal_officer(
    data: RecommendNodalOfficerRequest,
    user: dict = Depends(get_current_user),
):
    """Recommend a nodal officer"""
    recommendation = await ServiceService.recommend_nodal_officer(
        user["id"],
        data.dict(),
    )
    return recommendation.dict()


@router.get("/recommendations")
async def list_manager_recommendations(user: dict = Depends(get_current_user)):
    """List recommendations by a manager"""
    recommendations = await ServiceService.list_manager_recommendations(user["id"])
    return recommendations


@router.get("/manager-assignment")
async def get_manager_assignment(user: dict = Depends(get_current_user)):
    """Get manager assignment"""
    assignment = await ServiceService.get_manager_assignment(user["id"])
    if not assignment:
        raise HttpError(404, "Manager assignment not found")
    return assignment
