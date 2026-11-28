# 22 · Location picker

**Flutter:** `lib/features/profile/widgets/location_picker_sheet.dart`

**Purpose:** Record where the Farmer farms accurately and without typing, so weather and advice are for the right place. Today it covers Davao del Sur.

**Primary action:** Use my current location. Choosing the place by hand is always available.

## Layout

A bottom sheet that opens from the Location field in Profile edit. The whole sheet scrolls, so a long list never pushes anything off screen.

- **Province:** "Davao del Sur" is shown first, as the province everything below belongs to.
- **Use my current location:** a full-width outlined button. Location is requested only when the Farmer taps it, never earlier. If the phone's place is recognised down to the barangay, the sheet closes and fills the field. If only the city or municipality is recognised, it opens that list with "We found Bansalan. Now choose your barangay."
- **Choose by hand:** the Farmer picks a city or municipality (Davao City and Digos City are in the list), then a barangay. Both lists have a search field, and once a city is chosen there is a "Change city or municipality" link.
- **Result:** one line, "Barangay, City or Municipality, Davao del Sur", for example "Matti, Digos City, Davao del Sur".

## States

loading the list · cities · barangays · finding the location · permission off · phone location off · outside Davao del Sur · location unavailable (each shows a plain message above the list and leaves manual choosing open) · 200% text in EN, TL and CEB.

## Notes

- The list is the Philippine Statistics Authority's PSGC data for Davao del Sur: 11 cities and municipalities and 414 barangays, bundled in `assets/data/davao_del_sur_locations.json` so it works offline. Source is recorded in the file.
- Names from the phone ("City of Digos", "Digos") are matched loosely to the official list.
- Reverse lookup needs the phone's geocoder (Google Play services on Android). When it is missing or fails, the Farmer simply chooses by hand.
