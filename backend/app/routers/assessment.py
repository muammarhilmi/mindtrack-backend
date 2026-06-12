from fastapi import APIRouter, Depends

from app.dependencies.auth import get_current_user
from app.schemas.assessment import (
    AssessmentCreate,
    AssessmentResponse,
)
from app.services.assessment_service import create_assessment

router = APIRouter(
    prefix="/assessment",
    tags=["Assessment"],
)


@router.post(
    "/submit",
    response_model=AssessmentResponse,
)
def submit_assessment(
    data: AssessmentCreate,
    current_user: dict = Depends(get_current_user),
):
    return create_assessment(
        str(current_user["_id"]),
        data,
    )