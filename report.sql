COPY
(
  SELECT
    locations.id AS location_id,
    concat_ws(', ', locations.country, locations.city, locations.country, locations.zip_code) AS location_full_address,
    clients.id AS client_id,
    concat_ws(' ', clients.first_name, clients.last_name) AS client_full_name,
    clients.phone AS client_phone,
    clients.email AS client_email,
    string_agg(variations.name, '|') AS variation_names,
    COUNT(variations.name) AS variation_name,
    COUNT(slots.*) FILTER (WHERE purchases.referrer IS NOT NULL) AS bookings_with_referrer,
    COUNT(slots.*) FILTER (WHERE purchases.referrer IS NULL) AS bookings_without_referrer,
    COUNT(slots.*) FILTER (WHERE appointments.status != 'canceled') AS active_bookings_no,
    COUNT(slots.*) FILTER (WHERE appointments.status = 'canceled') AS canceled_bookings_no,
    SUM(purchases.purchased_at_price) FILTER (WHERE appointments.status = 'canceled') AS price_for_canceled,
    SUM(purchases.purchased_at_price) FILTER (WHERE appointments.status != 'canceled') AS price_for_active
  FROM clients
  LEFT JOIN appointments
    ON appointments.client_id = clients.id
  LEFT JOIN slots
    ON appointments.slot_id = slots.id
  LEFT JOIN locations
    ON slots.location_id = locations.id
  LEFT JOIN slot_variations
    ON slot_variations.slot_id = slots.id
  LEFT JOIN variations
    ON slot_variations.variation_id = variations.id
  LEFT JOIN purchases
    ON slots.purchase_id = purchases.id
  WHERE slots.end_at > now() - interval '2 weeks'
  GROUP BY locations.id, clients.id
  ORDER BY locations.id
)
TO '/tmp/report.csv'
WITH CSV DELIMITER ',' HEADER;
