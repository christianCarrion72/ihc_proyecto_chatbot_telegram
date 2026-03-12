import httpx


NOMINATIM_URL = "https://nominatim.openstreetmap.org/reverse"
USER_AGENT = "deli-go-delivery/1.0 (contacto@deligo.local)"


async def reverse_geocode(ubicacion_entrega: str) -> str | None:
  try:
    lat_str, lon_str = ubicacion_entrega.split(",", maxsplit=1)
    lat = float(lat_str)
    lon = float(lon_str)
  except Exception:
    return None

  params = {
    "lat": lat,
    "lon": lon,
    "format": "jsonv2",
  }

  headers = {"User-Agent": USER_AGENT}

  async with httpx.AsyncClient() as client:
    resp = await client.get(NOMINATIM_URL, params=params, headers=headers, timeout=10)

  if resp.status_code != 200:
    return None

  data = resp.json()
  direccion = data.get("display_name")
  if not direccion:
    return None

  return direccion

