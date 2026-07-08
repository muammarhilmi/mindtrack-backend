from fastapi import APIRouter, Depends, HTTPException

from app.dependencies.auth import get_current_user
from app.schemas.assessment import (
    AssessmentCreate,
    AssessmentResponse,
    AssessmentHistoryItem,
)
from app.services.assessment_service import (
    create_assessment,
    get_assessment_history,
    get_assessment_detail,
)

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


@router.get(
    "/history",
    response_model=list[AssessmentHistoryItem],
)
def history(
    current_user: dict = Depends(get_current_user),
):
    return get_assessment_history(
        str(current_user["_id"])
    )


@router.get(
    "/detail/{assessment_id}",
    response_model=AssessmentHistoryItem,
)
def detail(
    assessment_id: str,
    current_user: dict = Depends(get_current_user),
):
    item = get_assessment_detail(assessment_id)

    if not item:
        raise HTTPException(status_code=404, detail="Assessment tidak ditemukan")

    # Cegah user mengakses detail assessment milik user lain (IDOR)
    if item.get("user_id") != str(current_user["_id"]):
        raise HTTPException(status_code=403, detail="Tidak memiliki akses ke assessment ini")

    return item