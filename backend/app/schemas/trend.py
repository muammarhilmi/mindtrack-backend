from pydantic import BaseModel


class TrendMetric(BaseModel):
    score: int
    change: int


class WeeklyTrendResponse(BaseModel):
    burnout: TrendMetric
    anxiety: TrendMetric
    depression: TrendMetric
