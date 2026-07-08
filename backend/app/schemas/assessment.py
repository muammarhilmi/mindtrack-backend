from pydantic import BaseModel, Field, field_validator


class AssessmentCreate(BaseModel):
    # PHQ-9 (resmi 9 item, skala jawaban 0-3)
    phq_answers: list[int] = Field(
        ...,
        min_length=9,
        max_length=9,
        description="Jawaban PHQ-9, tiap item bernilai 0-3",
    )

    # GAD-7 (resmi 7 item, skala jawaban 0-3)
    gad_answers: list[int] = Field(
        ...,
        min_length=7,
        max_length=7,
        description="Jawaban GAD-7, tiap item bernilai 0-3",
    )

    # DASS-21 subskala Stress (resmi 7 item, skala jawaban 0-3)
    stress_answers: list[int] = Field(
        ...,
        min_length=7,
        max_length=7,
        description="Jawaban DASS-21 (subskala Stress), tiap item bernilai 0-3",
    )

    # Aktivitas Harian
    sleep_hours: float = Field(..., ge=0, le=24)
    sleep_quality: int = Field(..., ge=0, le=4)
    physical_activity: int = Field(..., ge=0, le=4)
    social_interaction: int = Field(..., ge=0, le=4)
    productivity: int = Field(..., ge=0, le=4)

    @field_validator("phq_answers", "gad_answers", "stress_answers")
    @classmethod
    def validate_answer_range(cls, v: list[int]) -> list[int]:
        if any(a < 0 or a > 3 for a in v):
            raise ValueError("Setiap jawaban harus bernilai antara 0-3")
        return v


class AssessmentResponse(BaseModel):
    # Skor mentah per instrumen
    phq_score: int
    gad_score: int
    stress_score: int

    # Kategori resmi per instrumen
    phq_level: str
    gad_level: str
    stress_level: str

    # Skor hasil perhitungan gabungan
    mental_percentage: int
    lifestyle_score: int
    final_score: int

    # Kategori akhir gabungan
    level: str

    # Aktivitas harian
    sleep_hours: float
    social_interaction: int
    productivity: int


class AssessmentHistoryItem(AssessmentResponse):
    id: str
    created_at: object  # datetime, dibiarkan object agar kompatibel dgn serialisasi Mongo