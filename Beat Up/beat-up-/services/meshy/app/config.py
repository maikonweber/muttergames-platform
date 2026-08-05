from __future__ import annotations

from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

_SERVICE_ROOT = Path(__file__).resolve().parents[1]


def _default_output_dir() -> Path:
	# services/meshy/app/config.py -> repo root
	return Path(__file__).resolve().parents[3] / "assets" / "generated"


class Settings(BaseSettings):
	model_config = SettingsConfigDict(
		env_file=str(_SERVICE_ROOT / ".env"),
		env_file_encoding="utf-8",
		extra="ignore",
	)

	meshy_api_key: str = ""
	meshy_base_url: str = "https://api.meshy.ai/openapi"
	host: str = "127.0.0.1"
	port: int = 8787
	output_dir: Path | None = None
	poll_interval_sec: float = 5.0
	poll_timeout_sec: float = 600.0

	def resolved_output_dir(self) -> Path:
		path = self.output_dir if self.output_dir else _default_output_dir()
		path.mkdir(parents=True, exist_ok=True)
		return path


settings = Settings()
