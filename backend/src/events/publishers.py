from __future__ import annotations

import logging

from src.events.models import Event

logger = logging.getLogger(__name__)


class EventPublisher:
    """Contrato base para publicar eventos del dominio con Event objects."""

    async def start(self) -> None:
        return None

    async def stop(self) -> None:
        return None

    async def publish(self, event: Event) -> None:
        raise NotImplementedError


class NullEventPublisher(EventPublisher):
    """No-op publisher para entornos sin eventos habilitados."""

    async def publish(self, event: Event) -> None:
        _ = event
        return None


class LogEventPublisher(EventPublisher):
    """Publica eventos como logs estructurados."""

    async def publish(self, event: Event) -> None:
        logger.info("event=%s version=%s source=%s payload=%s", event.event_name, event.version, event.source, event.payload)


class CompositeEventPublisher(EventPublisher):
    """Publisher que distribuye eventos a múltiples publishers en paralelo."""

    def __init__(self, publishers: list[EventPublisher]) -> None:
        self._publishers = publishers

    async def start(self) -> None:
        for publisher in self._publishers:
            try:
                await publisher.start()
            except Exception:
                logger.exception("Error iniciando publisher %s", type(publisher).__name__)
                raise

    async def stop(self) -> None:
        for publisher in self._publishers:
            try:
                await publisher.stop()
            except Exception:
                logger.exception("Error deteniendo publisher %s", type(publisher).__name__)

    async def publish(self, event: Event) -> None:
        """Publica en todos los publishers. El fallo en uno no bloquea otros."""
        errors = []
        for publisher in self._publishers:
            try:
                await publisher.publish(event)
            except Exception as exc:
                logger.warning("Error en publisher %s: %s", type(publisher).__name__, str(exc))
                errors.append(exc)

        # Si todos fallaron, relanzar el primer error
        if errors and len(errors) == len(self._publishers):
            raise errors[0]
