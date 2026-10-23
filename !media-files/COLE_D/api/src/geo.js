const EARTH_RADIUS_METERS = 6_371_000;

export function normalizeText(value) {
  return String(value ?? "")
    .normalize("NFD")
    .replace(/\p{M}/gu, "")
    .toLocaleLowerCase("pt-BR")
    .trim()
    .replace(/\s+/g, " ");
}

function assertCoordinate(point, label = "Coordenada") {
  if (!point || typeof point !== "object" || Array.isArray(point)
    || typeof point.lat !== "number" || !Number.isFinite(point.lat)
    || typeof point.lng !== "number" || !Number.isFinite(point.lng)
    || point.lat < -90 || point.lat > 90 || point.lng < -180 || point.lng > 180) {
    throw new TypeError(`${label} deve conter lat entre -90 e 90 e lng entre -180 e 180.`);
  }
}

export function distanceMeters(a, b) {
  assertCoordinate(a, "Origem");
  assertCoordinate(b, "Destino");
  const radians = Math.PI / 180;
  const latitudeDelta = (b.lat - a.lat) * radians;
  const longitudeDelta = (b.lng - a.lng) * radians;
  const latitudeA = a.lat * radians;
  const latitudeB = b.lat * radians;
  const haversine = Math.sin(latitudeDelta / 2) ** 2
    + Math.cos(latitudeA) * Math.cos(latitudeB) * Math.sin(longitudeDelta / 2) ** 2;
  return 2 * EARTH_RADIUS_METERS * Math.asin(Math.sqrt(Math.min(1, Math.max(0, haversine))));
}

/** Interpola uma distância em metros num percurso circular, incluindo o retorno à origem. */
export function interpolateRoute(route, distance) {
  if (!Array.isArray(route) || route.length === 0) {
    throw new TypeError("O percurso deve conter pelo menos uma coordenada.");
  }
  if (typeof distance !== "number" || !Number.isFinite(distance)) {
    throw new TypeError("A distância do percurso deve ser um número finito.");
  }
  route.forEach((point) => assertCoordinate(point));
  const segments = route.map((point, index) => ({
    start: point,
    end: route[(index + 1) % route.length],
    length: distanceMeters(point, route[(index + 1) % route.length]),
  }));
  const totalLength = segments.reduce((total, segment) => total + segment.length, 0);
  if (totalLength === 0) return { lat: route[0].lat, lng: route[0].lng };

  let remaining = ((distance % totalLength) + totalLength) % totalLength;
  for (const segment of segments) {
    if (segment.length === 0) continue;
    if (remaining <= segment.length) {
      const fraction = remaining / segment.length;
      // Usa o arco curto ao atravessar o antimeridiano.
      let longitudeDelta = segment.end.lng - segment.start.lng;
      if (longitudeDelta > 180) longitudeDelta -= 360;
      if (longitudeDelta < -180) longitudeDelta += 360;
      const longitude = segment.start.lng + longitudeDelta * fraction;
      return {
        lat: segment.start.lat + (segment.end.lat - segment.start.lat) * fraction,
        lng: ((longitude + 180) % 360 + 360) % 360 - 180,
      };
    }
    remaining -= segment.length;
  }
  return { lat: route[0].lat, lng: route[0].lng };
}
