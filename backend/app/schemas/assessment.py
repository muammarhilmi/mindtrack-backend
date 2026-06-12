from pydantic import BaseModel, Field

class AssessmentCreate(BaseModel):
    phq_answers: list[int] = Field(..., min_length=5, max_length=5)
    gad_answers: list[int] = Field(..., min_length=5, max_length=5)
    stress_answers: list[int] = Field(..., min_length=5, max_length=5)

    sleep_hours: float
    sleep_quality: int
    physical_activity: int
    social_interaction: int
    productivity: int


class AssessmentResponse(BaseModel):
    phq_score: int
    gad_score: int
    stress_score: int

    phq_level: str
    gad_level: str
    stress_level: str