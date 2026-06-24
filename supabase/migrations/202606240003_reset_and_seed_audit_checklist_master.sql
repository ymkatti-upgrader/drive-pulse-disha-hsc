-- Reset and reseed audit_checklist_master from audit-checklist-template.xlsx
BEGIN;

DELETE FROM audit_checklist_master;

INSERT INTO audit_checklist_master (
  checklist_code,
  version,
  section,
  area,
  chapter,
  classification,
  location_aspect,
  evaluation_question,
  evaluation_parameter,
  guest_experience_impact,
  facility_type,
  question,
  purpose,
  checking_method,
  additional_info,
  sop_reference,
  evidence_required,
  applicable_departments,
  status
) VALUES
(
    'DQ001',
    'v1-DQ001-001',
    'Facility',
    'Entrance',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Facility',
    'Entrance',
    'Primary Signage [Pylon] & Fascia Signage',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Direct',
    '3S',
    'Primary Signage [Pylon] & Fascia Signage',
    '* Potential Guests may not be able to find Dealer if they cannot see a clear Primary sign.

* Fascia makes a good impression on the Guests and shows available service facilities to motorists and pedestrians.

* Dealer Entry & Exit must be signposted to prevent Guest from getting lost and to show them the way as preferred',
    'Visual Check from Guest view point
1) All the Signage and Logo are as per Toyota Standards 
2) Signage should be clean and free from bird droppings, dust & stains.
3) Cleaning & Maintenance of the pylon & signages must be done on regular basis (Maintain a maintenance log of pylon general maintenance & electric maintenance)
4) Check if there is sufficient lighting at night. (Visual Check from Guest view point. Lights must be on, with all characters glowing, till 11 PM)
5) Signages provided in the floor are clearly visible (entry exit mark, bay marking & number, speed limit, walk-path etc.)
6) U-trust Wall signage is mandatory only if boundary wall is available at dealership',
    '1) Motorists should be able to clearly identify the primary signage from a minimum distance of 120 meters. Signage (all letters) should be glowing at night (till 11 PM).
2) All dealerships to have the latest DIVA standardsA of signage. In case dealer facility is not 3S, acceptance of non availability of the primary sign to be confirmed with TKM DD, unless dealer has formal consent from TKM in this regard.
3) Suitable signage of speed limit should be available in the dealership.
4) Operating hours should be same as actual operating hour and should be at all points in a dealer location (Main Entrance, Reception Entrance & Cashier) & in dealer website / google location.',
    '1) DIVA guidelines (Signage Standards)
2) Walkpath Standards (Safety)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ001',
    'v1-DQ001-002',
    'Facility',
    'Entrance',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Facility',
    'Entrance',
    'U Trust Front Facia Signage, U Trust Wall Signage & "Used Vehicle" on Pylon (applicable only for Integrated U-Trust facility',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Direct',
    '3S',
    'U Trust Front Facia Signage, U Trust Wall Signage & "Used Vehicle" on Pylon (applicable only for Integrated U-Trust facility',
    '* Potential Guests may not be able to find Dealer if they cannot see a clear Primary sign.

* Fascia makes a good impression on the Guests and shows available service facilities to motorists and pedestrians.

* Dealer Entry & Exit must be signposted to prevent Guest from getting lost and to show them the way as preferred',
    'Visual Check from Guest view point
1) All the Signage and Logo are as per Toyota Standards 
2) Signage should be clean and free from bird droppings, dust & stains.
3) Cleaning & Maintenance of the pylon & signages must be done on regular basis (Maintain a maintenance log of pylon general maintenance & electric maintenance)
4) Check if there is sufficient lighting at night. (Visual Check from Guest view point. Lights must be on, with all characters glowing, till 11 PM)
5) Signages provided in the floor are clearly visible (entry exit mark, bay marking & number, speed limit, walk-path etc.)
6) U-trust Wall signage is mandatory only if boundary wall is available at dealership',
    '1) Motorists should be able to clearly identify the primary signage from a minimum distance of 120 meters. Signage (all letters) should be glowing at night (till 11 PM).
2) All dealerships to have the latest DIVA standardsA of signage. In case dealer facility is not 3S, acceptance of non availability of the primary sign to be confirmed with TKM DD, unless dealer has formal consent from TKM in this regard.
3) Suitable signage of speed limit should be available in the dealership.
4) Operating hours should be same as actual operating hour and should be at all points in a dealer location (Main Entrance, Reception Entrance & Cashier) & in dealer website / google location.',
    '1) DIVA guidelines (Signage Standards)
2) Walkpath Standards (Safety)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ001',
    'v1-DQ001-003',
    'Facility',
    'Entrance',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Facility',
    'Entrance',
    'Display of environment, safety & other necessary policies in compliance with local authority',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Direct',
    '3S',
    'Display of environment, safety & other necessary policies in compliance with local authority',
    '* Potential Guests may not be able to find Dealer if they cannot see a clear Primary sign.

* Fascia makes a good impression on the Guests and shows available service facilities to motorists and pedestrians.

* Dealer Entry & Exit must be signposted to prevent Guest from getting lost and to show them the way as preferred',
    'Visual Check from Guest view point
1) All the Signage and Logo are as per Toyota Standards 
2) Signage should be clean and free from bird droppings, dust & stains.
3) Cleaning & Maintenance of the pylon & signages must be done on regular basis (Maintain a maintenance log of pylon general maintenance & electric maintenance)
4) Check if there is sufficient lighting at night. (Visual Check from Guest view point. Lights must be on, with all characters glowing, till 11 PM)
5) Signages provided in the floor are clearly visible (entry exit mark, bay marking & number, speed limit, walk-path etc.)
6) U-trust Wall signage is mandatory only if boundary wall is available at dealership',
    '1) Motorists should be able to clearly identify the primary signage from a minimum distance of 120 meters. Signage (all letters) should be glowing at night (till 11 PM).
2) All dealerships to have the latest DIVA standardsA of signage. In case dealer facility is not 3S, acceptance of non availability of the primary sign to be confirmed with TKM DD, unless dealer has formal consent from TKM in this regard.
3) Suitable signage of speed limit should be available in the dealership.
4) Operating hours should be same as actual operating hour and should be at all points in a dealer location (Main Entrance, Reception Entrance & Cashier) & in dealer website / google location.',
    '1) DIVA guidelines (Signage Standards)
2) Walkpath Standards (Safety)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ001',
    'v1-DQ001-004',
    'Facility',
    'Entrance',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Facility',
    'Entrance',
    'Display of Entry / Exit signages, Speed limit signages & Operating hours at the main entrance, in a clearly visible way.',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Direct',
    '3S',
    'Display of Entry / Exit signages, Speed limit signages & Operating hours at the main entrance, in a clearly visible way.',
    '* Potential Guests may not be able to find Dealer if they cannot see a clear Primary sign.

* Fascia makes a good impression on the Guests and shows available service facilities to motorists and pedestrians.

* Dealer Entry & Exit must be signposted to prevent Guest from getting lost and to show them the way as preferred',
    'Visual Check from Guest view point
1) All the Signage and Logo are as per Toyota Standards 
2) Signage should be clean and free from bird droppings, dust & stains.
3) Cleaning & Maintenance of the pylon & signages must be done on regular basis (Maintain a maintenance log of pylon general maintenance & electric maintenance)
4) Check if there is sufficient lighting at night. (Visual Check from Guest view point. Lights must be on, with all characters glowing, till 11 PM)
5) Signages provided in the floor are clearly visible (entry exit mark, bay marking & number, speed limit, walk-path etc.)
6) U-trust Wall signage is mandatory only if boundary wall is available at dealership',
    '1) Motorists should be able to clearly identify the primary signage from a minimum distance of 120 meters. Signage (all letters) should be glowing at night (till 11 PM).
2) All dealerships to have the latest DIVA standardsA of signage. In case dealer facility is not 3S, acceptance of non availability of the primary sign to be confirmed with TKM DD, unless dealer has formal consent from TKM in this regard.
3) Suitable signage of speed limit should be available in the dealership.
4) Operating hours should be same as actual operating hour and should be at all points in a dealer location (Main Entrance, Reception Entrance & Cashier) & in dealer website / google location.',
    '1) DIVA guidelines (Signage Standards)
2) Walkpath Standards (Safety)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ001',
    'v1-DQ001-005',
    'Facility',
    'Entrance',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Facility',
    'Entrance',
    'Dealer facility signage near the dealer main entrance with clearly identified signs (Guest Parking, Service Reception, Showroom , to guide the guest to respective areas)',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Direct',
    '3S',
    'Dealer facility signage near the dealer main entrance with clearly identified signs (Guest Parking, Service Reception, Showroom , to guide the guest to respective areas)',
    '* Potential Guests may not be able to find Dealer if they cannot see a clear Primary sign.

* Fascia makes a good impression on the Guests and shows available service facilities to motorists and pedestrians.

* Dealer Entry & Exit must be signposted to prevent Guest from getting lost and to show them the way as preferred',
    'Visual Check from Guest view point
1) All the Signage and Logo are as per Toyota Standards 
2) Signage should be clean and free from bird droppings, dust & stains.
3) Cleaning & Maintenance of the pylon & signages must be done on regular basis (Maintain a maintenance log of pylon general maintenance & electric maintenance)
4) Check if there is sufficient lighting at night. (Visual Check from Guest view point. Lights must be on, with all characters glowing, till 11 PM)
5) Signages provided in the floor are clearly visible (entry exit mark, bay marking & number, speed limit, walk-path etc.)
6) U-trust Wall signage is mandatory only if boundary wall is available at dealership',
    '1) Motorists should be able to clearly identify the primary signage from a minimum distance of 120 meters. Signage (all letters) should be glowing at night (till 11 PM).
2) All dealerships to have the latest DIVA standardsA of signage. In case dealer facility is not 3S, acceptance of non availability of the primary sign to be confirmed with TKM DD, unless dealer has formal consent from TKM in this regard.
3) Suitable signage of speed limit should be available in the dealership.
4) Operating hours should be same as actual operating hour and should be at all points in a dealer location (Main Entrance, Reception Entrance & Cashier) & in dealer website / google location.',
    '1) DIVA guidelines (Signage Standards)
2) Walkpath Standards (Safety)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ001',
    'v1-DQ001-006',
    'Facility',
    'Entrance',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Facility',
    'Entrance',
    'Walk-path in the guest & vehicle crossing area',
    'Does the Dealer Comply with the facility signages as per Distributor guidelines for below items?',
    'Direct',
    '3S',
    'Walk-path in the guest & vehicle crossing area',
    '* Potential Guests may not be able to find Dealer if they cannot see a clear Primary sign.

* Fascia makes a good impression on the Guests and shows available service facilities to motorists and pedestrians.

* Dealer Entry & Exit must be signposted to prevent Guest from getting lost and to show them the way as preferred',
    'Visual Check from Guest view point
1) All the Signage and Logo are as per Toyota Standards 
2) Signage should be clean and free from bird droppings, dust & stains.
3) Cleaning & Maintenance of the pylon & signages must be done on regular basis (Maintain a maintenance log of pylon general maintenance & electric maintenance)
4) Check if there is sufficient lighting at night. (Visual Check from Guest view point. Lights must be on, with all characters glowing, till 11 PM)
5) Signages provided in the floor are clearly visible (entry exit mark, bay marking & number, speed limit, walk-path etc.)
6) U-trust Wall signage is mandatory only if boundary wall is available at dealership',
    '1) Motorists should be able to clearly identify the primary signage from a minimum distance of 120 meters. Signage (all letters) should be glowing at night (till 11 PM).
2) All dealerships to have the latest DIVA standardsA of signage. In case dealer facility is not 3S, acceptance of non availability of the primary sign to be confirmed with TKM DD, unless dealer has formal consent from TKM in this regard.
3) Suitable signage of speed limit should be available in the dealership.
4) Operating hours should be same as actual operating hour and should be at all points in a dealer location (Main Entrance, Reception Entrance & Cashier) & in dealer website / google location.',
    '1) DIVA guidelines (Signage Standards)
2) Walkpath Standards (Safety)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ002',
    'v1-DQ002-001',
    'Facility',
    'Entrance',
    'Does the dealer has adequate number of parking bays as per the DIVA standard for the following purpose in sales area?',
    'Facility',
    'Entrance',
    'Guest vehicle parking availability, bay size and signages',
    'Does the dealer has adequate number of parking bays as per the DIVA standard for the following purpose in sales area?',
    'Direct',
    '3S',
    'Guest vehicle parking availability, bay size and signages',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view (as per approved plan)

* Signages to identify & guide the  customers towards parking bays

* Security guiding the customer for right parking bay',
    '1) Check the number of customer vehicle parking availability, as per TKM approved plan 
Guest vehicle Parking : [A -20 , B-10, C-7, D-7 & E/Satellite-5]
Test Drive Parking : A-9 [135 mt2], B-7 [105 mt2], C-5 [75 mt2], D-5 [75 mt2], E/Sat-2 [30 mt2]
2) Customer parking bay size must be 3m*5m, and must be clearly marked
3) Guest Vehicle parking & Test Drive should be in front of the showroom / near the dealer entrance (in case, if it is not near the entrance then valet parking must be provided)
4) Signages to identify the Guest parking''s & Test Drive parking [on floor & stand both]
5) Bays should not be marked in front of fire Hydrant access point and safe assembly points',
    '1) Check the facility drawing approved by DD & ensure no modifications in parking bays is done
2) Ensure that only Guest vehicles are parked in the Guest Parking bays & Test drive vehicles in Test-drive parking bays [Employee / Sales / Service / U-trust / dealer internal vehicles should not be parked in customer parking area]
3) If the available number of parking (as per TKM approved plan) is not sufficient to handle the current requirement (check during peak hour of showroom walk-ins), alternate arrangement to be made by the dealers (valet parking, additional bays)
4) Security must assist the guest during the parking',
    '1) DIVA guidelines (Parking bay Standards)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ002',
    'v1-DQ002-002',
    'Facility',
    'Entrance',
    'Does the dealer has adequate number of parking bays as per the DIVA standard for the following purpose in sales area?',
    'Facility',
    'Entrance',
    'Test Drive vehicle Parking availability, bay size and signages',
    'Does the dealer has adequate number of parking bays as per the DIVA standard for the following purpose in sales area?',
    'Direct',
    '3S',
    'Test Drive vehicle Parking availability, bay size and signages',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view (as per approved plan)

* Signages to identify & guide the  customers towards parking bays

* Security guiding the customer for right parking bay',
    '1) Check the number of customer vehicle parking availability, as per TKM approved plan 
Guest vehicle Parking : [A -20 , B-10, C-7, D-7 & E/Satellite-5]
Test Drive Parking : A-9 [135 mt2], B-7 [105 mt2], C-5 [75 mt2], D-5 [75 mt2], E/Sat-2 [30 mt2]
2) Customer parking bay size must be 3m*5m, and must be clearly marked
3) Guest Vehicle parking & Test Drive should be in front of the showroom / near the dealer entrance (in case, if it is not near the entrance then valet parking must be provided)
4) Signages to identify the Guest parking''s & Test Drive parking [on floor & stand both]
5) Bays should not be marked in front of fire Hydrant access point and safe assembly points',
    '1) Check the facility drawing approved by DD & ensure no modifications in parking bays is done
2) Ensure that only Guest vehicles are parked in the Guest Parking bays & Test drive vehicles in Test-drive parking bays [Employee / Sales / Service / U-trust / dealer internal vehicles should not be parked in customer parking area]
3) If the available number of parking (as per TKM approved plan) is not sufficient to handle the current requirement (check during peak hour of showroom walk-ins), alternate arrangement to be made by the dealers (valet parking, additional bays)
4) Security must assist the guest during the parking',
    '1) DIVA guidelines (Parking bay Standards)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ002',
    'v1-DQ002-003',
    'Facility',
    'Entrance',
    'Does the dealer has adequate number of parking bays as per the DIVA standard for the following purpose in sales area?',
    'Facility',
    'Entrance',
    'No Parking bay or Parked vehicles in front of Fire Hydrant point or safe assembly area',
    'Does the dealer has adequate number of parking bays as per the DIVA standard for the following purpose in sales area?',
    'Direct',
    '3S',
    'No Parking bay or Parked vehicles in front of Fire Hydrant point or safe assembly area',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view (as per approved plan)

* Signages to identify & guide the  customers towards parking bays

* Security guiding the customer for right parking bay',
    '1) Check the number of customer vehicle parking availability, as per TKM approved plan 
Guest vehicle Parking : [A -20 , B-10, C-7, D-7 & E/Satellite-5]
Test Drive Parking : A-9 [135 mt2], B-7 [105 mt2], C-5 [75 mt2], D-5 [75 mt2], E/Sat-2 [30 mt2]
2) Customer parking bay size must be 3m*5m, and must be clearly marked
3) Guest Vehicle parking & Test Drive should be in front of the showroom / near the dealer entrance (in case, if it is not near the entrance then valet parking must be provided)
4) Signages to identify the Guest parking''s & Test Drive parking [on floor & stand both]
5) Bays should not be marked in front of fire Hydrant access point and safe assembly points',
    '1) Check the facility drawing approved by DD & ensure no modifications in parking bays is done
2) Ensure that only Guest vehicles are parked in the Guest Parking bays & Test drive vehicles in Test-drive parking bays [Employee / Sales / Service / U-trust / dealer internal vehicles should not be parked in customer parking area]
3) If the available number of parking (as per TKM approved plan) is not sufficient to handle the current requirement (check during peak hour of showroom walk-ins), alternate arrangement to be made by the dealers (valet parking, additional bays)
4) Security must assist the guest during the parking',
    '1) DIVA guidelines (Parking bay Standards)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ003',
    'v1-DQ003-001',
    'Facility',
    'Entrance',
    'Does the dealer ensure the following points in the U-trust display area?',
    'Facility',
    'Entrance',
    'Display area should have bay marking with ''U Trust'' painted on floor (floor can be of any color',
    'Does the dealer ensure the following points in the U-trust display area?',
    'Direct',
    '3S',
    'Display area should have bay marking with ''U Trust'' painted on floor (floor can be of any color',
    '* To make sure that all Guests move smoothly without assistance using Signages

* Guests can easily identify the certified used car and best quote

* Branding of Used Car business inside the premises for walk-in customers in sales, service',
    '1) Physical check at display bay & vehicle condition
2) Refer to DD Layout plan vs actual availability of Display bay
3) Display bay standard dimension : 3m X 5m (Concrete / Pavers)
(Check Annexure attached for Images of correct POP designs)',
    '1) Bay marking
2) Vehicle Quality (Neatness and Cleanliness)
3) Refer U-trust POPs AnnexureA
4) DD Layout plan (for number of bays & location of bays)',
    '1) U-trust POP Annexure',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ003',
    'v1-DQ003-002',
    'Facility',
    'Entrance',
    'Does the dealer ensure the following points in the U-trust display area?',
    'Facility',
    'Entrance',
    'Vehicle in display should be neat & tidy with all required & correct POPs with correct vehicle information',
    'Does the dealer ensure the following points in the U-trust display area?',
    'Direct',
    '3S',
    'Vehicle in display should be neat & tidy with all required & correct POPs with correct vehicle information',
    '* To make sure that all Guests move smoothly without assistance using Signages

* Guests can easily identify the certified used car and best quote

* Branding of Used Car business inside the premises for walk-in customers in sales, service',
    '1) Physical check at display bay & vehicle condition
2) Refer to DD Layout plan vs actual availability of Display bay
3) Display bay standard dimension : 3m X 5m (Concrete / Pavers)
(Check Annexure attached for Images of correct POP designs)',
    '1) Bay marking
2) Vehicle Quality (Neatness and Cleanliness)
3) Refer U-trust POPs AnnexureA
4) DD Layout plan (for number of bays & location of bays)',
    '1) U-trust POP Annexure',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ004',
    'v1-DQ004-001',
    'Facility',
    'Entrance / Showroom / Service Reception',
    'Does the dealer has the faclity (Capsule / Digital POD1) for promotion of gloss STUDIO as per the facility type ?',
    'Facility',
    'Entrance / Showroom / Service Reception',
    'Gloss STUDIO Capsule [3S & 2S] availability, maintenance and usage',
    'Does the dealer has the faclity (Capsule / Digital POD1) for promotion of gloss STUDIO as per the facility type ?',
    'Direct',
    '3S',
    'Gloss STUDIO Capsule [3S & 2S] availability, maintenance and usage',
    '* Dealer need to maintain gloss STUDIO capsule/Digital POD1 as per the standard guidelines provided by TKM',
    'Capsule : 
1) Check for standard gloss STUDIO signage for Capsule [3S&2S] with good customer visibility
2) Capsule needs to be as per the guidelines shared by VCD to SBUs (concurred with DD)
Interactive Digital POD :
3) Proper functioning of Digital POD with updated details & pricing as per the standards
4) Digital pod to be placed by the side of reception desk (sales)',
    '1) Refer TKM provided gloss STUDIO capsule/digital pod guidelinesA
    a. No space constraint - gloss Capsule [Customer facing] 
    b. Space Constraint - Well Lit Closed Space [Not Customer facing]
2) Ensure proper lighting (minimum 585 lux) for 1 bay
3) Applicator should be wearing neat & tidy uniform as per the design standard provided by TKM.',
    '1) Gloss Studio Capsule/Digital POD guidelines',
    false,
    '["Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ004',
    'v1-DQ004-002',
    'Facility',
    'Entrance / Showroom / Service Reception',
    'Does the dealer has the faclity (Capsule / Digital POD1) for promotion of gloss STUDIO as per the facility type ?',
    'Facility',
    'Entrance / Showroom / Service Reception',
    'Interactive Digital POD [1S] (Optional with updated details.)',
    'Does the dealer has the faclity (Capsule / Digital POD1) for promotion of gloss STUDIO as per the facility type ?',
    'Direct',
    '3S',
    'Interactive Digital POD [1S] (Optional with updated details.)',
    '* Dealer need to maintain gloss STUDIO capsule/Digital POD1 as per the standard guidelines provided by TKM',
    'Capsule : 
1) Check for standard gloss STUDIO signage for Capsule [3S&2S] with good customer visibility
2) Capsule needs to be as per the guidelines shared by VCD to SBUs (concurred with DD)
Interactive Digital POD :
3) Proper functioning of Digital POD with updated details & pricing as per the standards
4) Digital pod to be placed by the side of reception desk (sales)',
    '1) Refer TKM provided gloss STUDIO capsule/digital pod guidelinesA
    a. No space constraint - gloss Capsule [Customer facing] 
    b. Space Constraint - Well Lit Closed Space [Not Customer facing]
2) Ensure proper lighting (minimum 585 lux) for 1 bay
3) Applicator should be wearing neat & tidy uniform as per the design standard provided by TKM.',
    '1) Gloss Studio Capsule/Digital POD guidelines',
    false,
    '["Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ005',
    'v1-DQ005-001',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer has following facilities in the reception area of Sales & Service and maintained as per DIVA guidelines?',
    'Facility',
    'Showroom & Service Reception',
    'All the available guest service facilities signboards are displayed in reception area and clearly visible to guests',
    'Does dealer has following facilities in the reception area of Sales & Service and maintained as per DIVA guidelines?',
    'Direct',
    '3S',
    'All the available guest service facilities signboards are displayed in reception area and clearly visible to guests',
    '*To make sure that all Guests move smoothly without assistance using Signages

*Guests and Dealer staff should be able to easily identify Guest parking and service vehicle parking as preferred by the Dealer.

*It is very important to post notification of different payment methods so that the Guest can know without asking anyone from the Dealer.',
    '1) Visually Check all signages & creatives (from Guest view point)
2) Check for ''Payment Methods'' signage or information in the reception and cashier area',
    'Dealer should follow the latest DIVA standardsA of signage. 
1) The  Guest facilities should be identified with clear signage and Clearly visible to Guests. Following are the list of signages to be displayed in the showroom & Service reception
i. Showroom - Accessories, U-trust, Finance, New car delivery area
ii. Service area - General Service, BP Service
iii. Guest facilities - Toilet, Lounge, Cafeteria
iv. Others - Cashier, Insurance Desk
2) The payment method display in the lounge area and at Cashier point
3) Optional: Payment method may additionally be mentioned in the sales brochures, dealer sales / service staff business cards',
    '1) DIVA guidelines (Inside Facility Signages)
2) U-trust desk creatives (Front and Back)
3) Finance desk creatives (Front)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ005',
    'v1-DQ005-002',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer has following facilities in the reception area of Sales & Service and maintained as per DIVA guidelines?',
    'Facility',
    'Showroom & Service Reception',
    'Respective Guest service facilities signboards are displayed at respective points (Lounge, Toilets, Cashier, Value chain areas - Accessory; Finance; U-Trust',
    'Does dealer has following facilities in the reception area of Sales & Service and maintained as per DIVA guidelines?',
    'Direct',
    '3S',
    'Respective Guest service facilities signboards are displayed at respective points (Lounge, Toilets, Cashier, Value chain areas - Accessory; Finance; U-Trust',
    '*To make sure that all Guests move smoothly without assistance using Signages

*Guests and Dealer staff should be able to easily identify Guest parking and service vehicle parking as preferred by the Dealer.

*It is very important to post notification of different payment methods so that the Guest can know without asking anyone from the Dealer.',
    '1) Visually Check all signages & creatives (from Guest view point)
2) Check for ''Payment Methods'' signage or information in the reception and cashier area',
    'Dealer should follow the latest DIVA standardsA of signage. 
1) The  Guest facilities should be identified with clear signage and Clearly visible to Guests. Following are the list of signages to be displayed in the showroom & Service reception
i. Showroom - Accessories, U-trust, Finance, New car delivery area
ii. Service area - General Service, BP Service
iii. Guest facilities - Toilet, Lounge, Cafeteria
iv. Others - Cashier, Insurance Desk
2) The payment method display in the lounge area and at Cashier point
3) Optional: Payment method may additionally be mentioned in the sales brochures, dealer sales / service staff business cards',
    '1) DIVA guidelines (Inside Facility Signages)
2) U-trust desk creatives (Front and Back)
3) Finance desk creatives (Front)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ005',
    'v1-DQ005-003',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer has following facilities in the reception area of Sales & Service and maintained as per DIVA guidelines?',
    'Facility',
    'Showroom & Service Reception',
    'U Trust desk with table front creative & backdrop creative* (applicable only for Integrated U-Trust facility [Backdrop creative not required in case if no wall behind the desk])',
    'Does dealer has following facilities in the reception area of Sales & Service and maintained as per DIVA guidelines?',
    'Direct',
    '3S',
    'U Trust desk with table front creative & backdrop creative* (applicable only for Integrated U-Trust facility [Backdrop creative not required in case if no wall behind the desk])',
    '*To make sure that all Guests move smoothly without assistance using Signages

*Guests and Dealer staff should be able to easily identify Guest parking and service vehicle parking as preferred by the Dealer.

*It is very important to post notification of different payment methods so that the Guest can know without asking anyone from the Dealer.',
    '1) Visually Check all signages & creatives (from Guest view point)
2) Check for ''Payment Methods'' signage or information in the reception and cashier area',
    'Dealer should follow the latest DIVA standardsA of signage. 
1) The  Guest facilities should be identified with clear signage and Clearly visible to Guests. Following are the list of signages to be displayed in the showroom & Service reception
i. Showroom - Accessories, U-trust, Finance, New car delivery area
ii. Service area - General Service, BP Service
iii. Guest facilities - Toilet, Lounge, Cafeteria
iv. Others - Cashier, Insurance Desk
2) The payment method display in the lounge area and at Cashier point
3) Optional: Payment method may additionally be mentioned in the sales brochures, dealer sales / service staff business cards',
    '1) DIVA guidelines (Inside Facility Signages)
2) U-trust desk creatives (Front and Back)
3) Finance desk creatives (Front)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ005',
    'v1-DQ005-004',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer has following facilities in the reception area of Sales & Service and maintained as per DIVA guidelines?',
    'Facility',
    'Showroom & Service Reception',
    'Finance desk with table front creative',
    'Does dealer has following facilities in the reception area of Sales & Service and maintained as per DIVA guidelines?',
    'Direct',
    '3S',
    'Finance desk with table front creative',
    '*To make sure that all Guests move smoothly without assistance using Signages

*Guests and Dealer staff should be able to easily identify Guest parking and service vehicle parking as preferred by the Dealer.

*It is very important to post notification of different payment methods so that the Guest can know without asking anyone from the Dealer.',
    '1) Visually Check all signages & creatives (from Guest view point)
2) Check for ''Payment Methods'' signage or information in the reception and cashier area',
    'Dealer should follow the latest DIVA standardsA of signage. 
1) The  Guest facilities should be identified with clear signage and Clearly visible to Guests. Following are the list of signages to be displayed in the showroom & Service reception
i. Showroom - Accessories, U-trust, Finance, New car delivery area
ii. Service area - General Service, BP Service
iii. Guest facilities - Toilet, Lounge, Cafeteria
iv. Others - Cashier, Insurance Desk
2) The payment method display in the lounge area and at Cashier point
3) Optional: Payment method may additionally be mentioned in the sales brochures, dealer sales / service staff business cards',
    '1) DIVA guidelines (Inside Facility Signages)
2) U-trust desk creatives (Front and Back)
3) Finance desk creatives (Front)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ005',
    'v1-DQ005-005',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer has following facilities in the reception area of Sales & Service and maintained as per DIVA guidelines?',
    'Facility',
    'Showroom & Service Reception',
    'All payment methods that the Dealer can accept are clearly indicated in the booking form, reception area & Cashier counter & informed to customer by GEM',
    'Does dealer has following facilities in the reception area of Sales & Service and maintained as per DIVA guidelines?',
    'Direct',
    '3S',
    'All payment methods that the Dealer can accept are clearly indicated in the booking form, reception area & Cashier counter & informed to customer by GEM',
    '*To make sure that all Guests move smoothly without assistance using Signages

*Guests and Dealer staff should be able to easily identify Guest parking and service vehicle parking as preferred by the Dealer.

*It is very important to post notification of different payment methods so that the Guest can know without asking anyone from the Dealer.',
    '1) Visually Check all signages & creatives (from Guest view point)
2) Check for ''Payment Methods'' signage or information in the reception and cashier area',
    'Dealer should follow the latest DIVA standardsA of signage. 
1) The  Guest facilities should be identified with clear signage and Clearly visible to Guests. Following are the list of signages to be displayed in the showroom & Service reception
i. Showroom - Accessories, U-trust, Finance, New car delivery area
ii. Service area - General Service, BP Service
iii. Guest facilities - Toilet, Lounge, Cafeteria
iv. Others - Cashier, Insurance Desk
2) The payment method display in the lounge area and at Cashier point
3) Optional: Payment method may additionally be mentioned in the sales brochures, dealer sales / service staff business cards',
    '1) DIVA guidelines (Inside Facility Signages)
2) U-trust desk creatives (Front and Back)
3) Finance desk creatives (Front)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ006',
    'v1-DQ006-001',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Facility',
    'Showroom & Service Reception',
    'Reception desk & Showroom Hostess (showroom / Lobby in charge (Service))',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Direct',
    '3S',
    'Reception desk & Showroom Hostess (showroom / Lobby in charge (Service))',
    '*Convenient and comfortable experience for guest inside the showroom while they wait inside the premises',
    '1) Showroom Reception desk and Value chain area (Accessory, Finance & U-trust) to be as per facility guide. 
2) Tiles should be neat & not broken in reception & display zone  [Should be free from marks, cracks & color fading].
3) Showroom & Service reception illumination should be sufficient [>800 lux]. 
4) Temperature of the showroom & Service reception should be maintained considering the seasonality [<25 degrees].    
5) 4S condition of the new car delivery & waiting area [Cleaned sofa , working condition of A/C etc.]',
    '1) Visual Check all waiting and seating areas (from Guest view point) & creatives
2) Smell, cleanliness, fragrance in the guest waiting or seating areas.
3) Refer DIVA guidelineA',
    '1) DIVA guideline (Guest waiting & Seating Areas)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ006',
    'v1-DQ006-002',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Facility',
    'Showroom & Service Reception',
    '4S & Hygiene in the showroom & Service reception area (Neat & clean with no clutter',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Direct',
    '3S',
    '4S & Hygiene in the showroom & Service reception area (Neat & clean with no clutter',
    '*Convenient and comfortable experience for guest inside the showroom while they wait inside the premises',
    '1) Showroom Reception desk and Value chain area (Accessory, Finance & U-trust) to be as per facility guide. 
2) Tiles should be neat & not broken in reception & display zone  [Should be free from marks, cracks & color fading].
3) Showroom & Service reception illumination should be sufficient [>800 lux]. 
4) Temperature of the showroom & Service reception should be maintained considering the seasonality [<25 degrees].    
5) 4S condition of the new car delivery & waiting area [Cleaned sofa , working condition of A/C etc.]',
    '1) Visual Check all waiting and seating areas (from Guest view point) & creatives
2) Smell, cleanliness, fragrance in the guest waiting or seating areas.
3) Refer DIVA guidelineA',
    '1) DIVA guideline (Guest waiting & Seating Areas)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ006',
    'v1-DQ006-003',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Facility',
    'Showroom & Service Reception',
    'Good illumination across the showroom & Service reception area',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Direct',
    '3S',
    'Good illumination across the showroom & Service reception area',
    '*Convenient and comfortable experience for guest inside the showroom while they wait inside the premises',
    '1) Showroom Reception desk and Value chain area (Accessory, Finance & U-trust) to be as per facility guide. 
2) Tiles should be neat & not broken in reception & display zone  [Should be free from marks, cracks & color fading].
3) Showroom & Service reception illumination should be sufficient [>800 lux]. 
4) Temperature of the showroom & Service reception should be maintained considering the seasonality [<25 degrees].    
5) 4S condition of the new car delivery & waiting area [Cleaned sofa , working condition of A/C etc.]',
    '1) Visual Check all waiting and seating areas (from Guest view point) & creatives
2) Smell, cleanliness, fragrance in the guest waiting or seating areas.
3) Refer DIVA guidelineA',
    '1) DIVA guideline (Guest waiting & Seating Areas)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ006',
    'v1-DQ006-004',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Facility',
    'Showroom & Service Reception',
    'Air-condition (AC in working condition & regular maintenance is done)',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Direct',
    '3S',
    'Air-condition (AC in working condition & regular maintenance is done)',
    '*Convenient and comfortable experience for guest inside the showroom while they wait inside the premises',
    '1) Showroom Reception desk and Value chain area (Accessory, Finance & U-trust) to be as per facility guide. 
2) Tiles should be neat & not broken in reception & display zone  [Should be free from marks, cracks & color fading].
3) Showroom & Service reception illumination should be sufficient [>800 lux]. 
4) Temperature of the showroom & Service reception should be maintained considering the seasonality [<25 degrees].    
5) 4S condition of the new car delivery & waiting area [Cleaned sofa , working condition of A/C etc.]',
    '1) Visual Check all waiting and seating areas (from Guest view point) & creatives
2) Smell, cleanliness, fragrance in the guest waiting or seating areas.
3) Refer DIVA guidelineA',
    '1) DIVA guideline (Guest waiting & Seating Areas)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ006',
    'v1-DQ006-005',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Facility',
    'Showroom & Service Reception',
    'Well organized & well maintained discussion area (availability & condition of table & chairs',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Direct',
    '3S',
    'Well organized & well maintained discussion area (availability & condition of table & chairs',
    '*Convenient and comfortable experience for guest inside the showroom while they wait inside the premises',
    '1) Showroom Reception desk and Value chain area (Accessory, Finance & U-trust) to be as per facility guide. 
2) Tiles should be neat & not broken in reception & display zone  [Should be free from marks, cracks & color fading].
3) Showroom & Service reception illumination should be sufficient [>800 lux]. 
4) Temperature of the showroom & Service reception should be maintained considering the seasonality [<25 degrees].    
5) 4S condition of the new car delivery & waiting area [Cleaned sofa , working condition of A/C etc.]',
    '1) Visual Check all waiting and seating areas (from Guest view point) & creatives
2) Smell, cleanliness, fragrance in the guest waiting or seating areas.
3) Refer DIVA guidelineA',
    '1) DIVA guideline (Guest waiting & Seating Areas)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ006',
    'v1-DQ006-006',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Facility',
    'Showroom & Service Reception',
    'Designated New car delivery area as per DIVA guidelines, with comfortable waiting area for new vehicle customers',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Direct',
    '3S',
    'Designated New car delivery area as per DIVA guidelines, with comfortable waiting area for new vehicle customers',
    '*Convenient and comfortable experience for guest inside the showroom while they wait inside the premises',
    '1) Showroom Reception desk and Value chain area (Accessory, Finance & U-trust) to be as per facility guide. 
2) Tiles should be neat & not broken in reception & display zone  [Should be free from marks, cracks & color fading].
3) Showroom & Service reception illumination should be sufficient [>800 lux]. 
4) Temperature of the showroom & Service reception should be maintained considering the seasonality [<25 degrees].    
5) 4S condition of the new car delivery & waiting area [Cleaned sofa , working condition of A/C etc.]',
    '1) Visual Check all waiting and seating areas (from Guest view point) & creatives
2) Smell, cleanliness, fragrance in the guest waiting or seating areas.
3) Refer DIVA guidelineA',
    '1) DIVA guideline (Guest waiting & Seating Areas)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ006',
    'v1-DQ006-007',
    'Facility',
    'Showroom & Service Reception',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Facility',
    'Showroom & Service Reception',
    'Is the Showroom hostess introducing the Facilities, eg Kids Play area to the eligible Customers',
    'Does dealer ensures better guest experience in showroom & Service reception by providing the below facilities?',
    'Direct',
    '3S',
    'Is the Showroom hostess introducing the Facilities, eg Kids Play area to the eligible Customers',
    '*Convenient and comfortable experience for guest inside the showroom while they wait inside the premises',
    '1) Showroom Reception desk and Value chain area (Accessory, Finance & U-trust) to be as per facility guide. 
2) Tiles should be neat & not broken in reception & display zone  [Should be free from marks, cracks & color fading].
3) Showroom & Service reception illumination should be sufficient [>800 lux]. 
4) Temperature of the showroom & Service reception should be maintained considering the seasonality [<25 degrees].    
5) 4S condition of the new car delivery & waiting area [Cleaned sofa , working condition of A/C etc.]',
    '1) Visual Check all waiting and seating areas (from Guest view point) & creatives
2) Smell, cleanliness, fragrance in the guest waiting or seating areas.
3) Refer DIVA guidelineA',
    '1) DIVA guideline (Guest waiting & Seating Areas)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ007',
    'v1-DQ007-001',
    'Facility',
    'Showroom',
    'Does dealer displays New vehicles in the showroom as per guideline mentioned in "Model  Launch guide  ?',
    'Facility',
    'Showroom',
    'New vehicle display area with displays as per DIVA facility standards, including Focus model display',
    'Does dealer displays New vehicles in the showroom as per guideline mentioned in "Model  Launch guide  ?',
    'Direct',
    '3S',
    'New vehicle display area with displays as per DIVA facility standards, including Focus model display',
    '*Guest can easily see the new vehicle key features and aesthetic sale point of view.

* Branding of vehicles for guest waiting in the showroom and service areas to see the product',
    'Check the following points about display cars
1) Ensuring the branding at dealership as per launch guide (Gate arch/ Table top/  Test drive car sticker)
2) Display cars must be kept clean and in good condition always
3) Display area should be free from obstacles and should have enough space for customers to move around easily.
4) Each vertical should have at least one display car (Small, Mid & Flagship)
5) New launch or focus models should be displayed in the highlight zone
6) Change the display car once a week (preferably change to different color)
7) After removing the car from display, PDI must be done and restore the car to original condition (Check the PDI document of car and confirm that PDI is performed after the display).',
    '1) Refer Model Launch guide / SBU guideline; PDI Check sheet 
2) Standard car display area based on category of dealership: A-9 , B-7, C-6, D-5, Satellite / E-2 
3) Staff must cover ornaments / belt buckle and ensure no damages during demo of vehicles
4) Take necessary steps to protect the frequently touched parts / areas (Door handle, instrument panel, switches, seats, steering, arm rest and peddles) & cover the floor of the car & foot rest areas with floor mats.
5) Display Car must not be started / operated in the showroom.
6) Is the recommended materials displayed in the vehicle. Eg: TGA Floor Mat Campaign',
    '1) Launch guide (Model wise)
2) TDS (Transit, Display & Stock) guidebook',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ007',
    'v1-DQ007-002',
    'Facility',
    'Showroom',
    'Does dealer displays New vehicles in the showroom as per guideline mentioned in "Model  Launch guide  ?',
    'Facility',
    'Showroom',
    'Display vehicles are as per TKM guideline and maintained in good condition',
    'Does dealer displays New vehicles in the showroom as per guideline mentioned in "Model  Launch guide  ?',
    'Direct',
    '3S',
    'Display vehicles are as per TKM guideline and maintained in good condition',
    '*Guest can easily see the new vehicle key features and aesthetic sale point of view.

* Branding of vehicles for guest waiting in the showroom and service areas to see the product',
    'Check the following points about display cars
1) Ensuring the branding at dealership as per launch guide (Gate arch/ Table top/  Test drive car sticker)
2) Display cars must be kept clean and in good condition always
3) Display area should be free from obstacles and should have enough space for customers to move around easily.
4) Each vertical should have at least one display car (Small, Mid & Flagship)
5) New launch or focus models should be displayed in the highlight zone
6) Change the display car once a week (preferably change to different color)
7) After removing the car from display, PDI must be done and restore the car to original condition (Check the PDI document of car and confirm that PDI is performed after the display).',
    '1) Refer Model Launch guide / SBU guideline; PDI Check sheet 
2) Standard car display area based on category of dealership: A-9 , B-7, C-6, D-5, Satellite / E-2 
3) Staff must cover ornaments / belt buckle and ensure no damages during demo of vehicles
4) Take necessary steps to protect the frequently touched parts / areas (Door handle, instrument panel, switches, seats, steering, arm rest and peddles) & cover the floor of the car & foot rest areas with floor mats.
5) Display Car must not be started / operated in the showroom.
6) Is the recommended materials displayed in the vehicle. Eg: TGA Floor Mat Campaign',
    '1) Launch guide (Model wise)
2) TDS (Transit, Display & Stock) guidebook',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ007',
    'v1-DQ007-003',
    'Facility',
    'Showroom',
    'Does dealer displays New vehicles in the showroom as per guideline mentioned in "Model  Launch guide  ?',
    'Facility',
    'Showroom',
    'Branding as per the launch guide',
    'Does dealer displays New vehicles in the showroom as per guideline mentioned in "Model  Launch guide  ?',
    'Direct',
    '3S',
    'Branding as per the launch guide',
    '*Guest can easily see the new vehicle key features and aesthetic sale point of view.

* Branding of vehicles for guest waiting in the showroom and service areas to see the product',
    'Check the following points about display cars
1) Ensuring the branding at dealership as per launch guide (Gate arch/ Table top/  Test drive car sticker)
2) Display cars must be kept clean and in good condition always
3) Display area should be free from obstacles and should have enough space for customers to move around easily.
4) Each vertical should have at least one display car (Small, Mid & Flagship)
5) New launch or focus models should be displayed in the highlight zone
6) Change the display car once a week (preferably change to different color)
7) After removing the car from display, PDI must be done and restore the car to original condition (Check the PDI document of car and confirm that PDI is performed after the display).',
    '1) Refer Model Launch guide / SBU guideline; PDI Check sheet 
2) Standard car display area based on category of dealership: A-9 , B-7, C-6, D-5, Satellite / E-2 
3) Staff must cover ornaments / belt buckle and ensure no damages during demo of vehicles
4) Take necessary steps to protect the frequently touched parts / areas (Door handle, instrument panel, switches, seats, steering, arm rest and peddles) & cover the floor of the car & foot rest areas with floor mats.
5) Display Car must not be started / operated in the showroom.
6) Is the recommended materials displayed in the vehicle. Eg: TGA Floor Mat Campaign',
    '1) Launch guide (Model wise)
2) TDS (Transit, Display & Stock) guidebook',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ007',
    'v1-DQ007-004',
    'Facility',
    'Showroom',
    'Does dealer displays New vehicles in the showroom as per guideline mentioned in "Model  Launch guide  ?',
    'Facility',
    'Showroom',
    'PDI completion of previously displayed car in the showroom',
    'Does dealer displays New vehicles in the showroom as per guideline mentioned in "Model  Launch guide  ?',
    'Direct',
    '3S',
    'PDI completion of previously displayed car in the showroom',
    '*Guest can easily see the new vehicle key features and aesthetic sale point of view.

* Branding of vehicles for guest waiting in the showroom and service areas to see the product',
    'Check the following points about display cars
1) Ensuring the branding at dealership as per launch guide (Gate arch/ Table top/  Test drive car sticker)
2) Display cars must be kept clean and in good condition always
3) Display area should be free from obstacles and should have enough space for customers to move around easily.
4) Each vertical should have at least one display car (Small, Mid & Flagship)
5) New launch or focus models should be displayed in the highlight zone
6) Change the display car once a week (preferably change to different color)
7) After removing the car from display, PDI must be done and restore the car to original condition (Check the PDI document of car and confirm that PDI is performed after the display).',
    '1) Refer Model Launch guide / SBU guideline; PDI Check sheet 
2) Standard car display area based on category of dealership: A-9 , B-7, C-6, D-5, Satellite / E-2 
3) Staff must cover ornaments / belt buckle and ensure no damages during demo of vehicles
4) Take necessary steps to protect the frequently touched parts / areas (Door handle, instrument panel, switches, seats, steering, arm rest and peddles) & cover the floor of the car & foot rest areas with floor mats.
5) Display Car must not be started / operated in the showroom.
6) Is the recommended materials displayed in the vehicle. Eg: TGA Floor Mat Campaign',
    '1) Launch guide (Model wise)
2) TDS (Transit, Display & Stock) guidebook',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ008',
    'v1-DQ008-001',
    'Brand Promotion',
    'Showroom & Service Reception',
    'Does the dealer adhere to all the brand guidelines on all displays and digital / social media communication?',
    'Brand Promotion',
    'Showroom & Service Reception',
    'Logo and Font Type in all displays',
    'Does the dealer adhere to all the brand guidelines on all displays and digital / social media communication?',
    'Indirect',
    '3S',
    'Logo and Font Type in all displays',
    '*Ensures the proper marketing and promotion of all products and services to all guests.',
    'Check the following for brand guidelines in displays and digital / social media communication 
1) Logo : 
- Usage of Toyota Stacked up logo and Awesome Unit
- Placement : Toyota logo at the Right Top Corner  
2) Font : Toyota Type 
3) Creatives : Utilize the product creatives developed by TKM Support Office team (Available in Google Link)
4) Avoid dealer company name in the creatives (E.g. :"XXXXX Toyota" to be used, not the registered company name)
5)Dealership Logo shouldn’t be bigger than two third of the Toyota logo height, it can be placed at Top Left / Bottom Left leaving sufficient breathing space (Similar to Toyota Logo)
6)Dealership Logo to be in the same color as Toyota Logo.',
    '1) Refer brand guidelinesA (Latest)',
    '1) Brand Guidelines (Latest)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ008',
    'v1-DQ008-002',
    'Brand Promotion',
    'Showroom & Service Reception',
    'Does the dealer adhere to all the brand guidelines on all displays and digital / social media communication?',
    'Brand Promotion',
    'Showroom & Service Reception',
    'Updated Product creatives as per TKM Support Office team',
    'Does the dealer adhere to all the brand guidelines on all displays and digital / social media communication?',
    'Indirect',
    '3S',
    'Updated Product creatives as per TKM Support Office team',
    '*Ensures the proper marketing and promotion of all products and services to all guests.',
    'Check the following for brand guidelines in displays and digital / social media communication 
1) Logo : 
- Usage of Toyota Stacked up logo and Awesome Unit
- Placement : Toyota logo at the Right Top Corner  
2) Font : Toyota Type 
3) Creatives : Utilize the product creatives developed by TKM Support Office team (Available in Google Link)
4) Avoid dealer company name in the creatives (E.g. :"XXXXX Toyota" to be used, not the registered company name)
5)Dealership Logo shouldn’t be bigger than two third of the Toyota logo height, it can be placed at Top Left / Bottom Left leaving sufficient breathing space (Similar to Toyota Logo)
6)Dealership Logo to be in the same color as Toyota Logo.',
    '1) Refer brand guidelinesA (Latest)',
    '1) Brand Guidelines (Latest)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ008',
    'v1-DQ008-003',
    'Brand Promotion',
    'Showroom & Service Reception',
    'Does the dealer adhere to all the brand guidelines on all displays and digital / social media communication?',
    'Brand Promotion',
    'Showroom & Service Reception',
    'No Dealer registered company name in the creatives',
    'Does the dealer adhere to all the brand guidelines on all displays and digital / social media communication?',
    'Indirect',
    '3S',
    'No Dealer registered company name in the creatives',
    '*Ensures the proper marketing and promotion of all products and services to all guests.',
    'Check the following for brand guidelines in displays and digital / social media communication 
1) Logo : 
- Usage of Toyota Stacked up logo and Awesome Unit
- Placement : Toyota logo at the Right Top Corner  
2) Font : Toyota Type 
3) Creatives : Utilize the product creatives developed by TKM Support Office team (Available in Google Link)
4) Avoid dealer company name in the creatives (E.g. :"XXXXX Toyota" to be used, not the registered company name)
5)Dealership Logo shouldn’t be bigger than two third of the Toyota logo height, it can be placed at Top Left / Bottom Left leaving sufficient breathing space (Similar to Toyota Logo)
6)Dealership Logo to be in the same color as Toyota Logo.',
    '1) Refer brand guidelinesA (Latest)',
    '1) Brand Guidelines (Latest)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ009',
    'v1-DQ009-001',
    'Facility',
    'Showroom & Accessory Area',
    'Does the dealer display all accessories and the relevant information in a convenient and transparent way?',
    'Facility',
    'Showroom & Accessory Area',
    'Accessory display to be available in the showroom as per the standard, to assist the guest to choose right accessories to their car',
    'Does the dealer display all accessories and the relevant information in a convenient and transparent way?',
    'Direct',
    '3S',
    'Accessory display to be available in the showroom as per the standard, to assist the guest to choose right accessories to their car',
    '*Ensures the convenience of choosing on accessories by guest

*Transparency in decision making by guest for accessories.',
    'Check the following points as a part of Accessory Offering in showroom:
1) Accessories for active Models (Vehicle Sale/ month >=5)  to be showcased in Display Area
2) Placard / Sticker with Accessory Name, Cost & EMI near the Accessories in Display Zone / Area
3) Display of Accessories on all Test Drive Vehicles [>= per car target]
4) Display of Accessories on all vehicles displayed in showroom [>= per car target]
5) Availability of Latest Accessory Brochure & Pricelist in Sales Showroom for all active models (Digital or Printed)
6) Availability of Customized Accessory Package for Active Models [e.g. Basic, Premium, Luxury]
7) Screen @ Dealership to showcase Car Configurator to Customer [TV / Laptop or iPad]',
    '1) Accessory showcase in Exclusive Display Area along with Placard with details
2) Accessory display on test drive & showroom vehicles is must. Incase of display vehicles, accessories can be displaced using stickers which can be easily removed (Considering that display vehicle is changed weekly).
3) Incase of booked vehicle to be displayed, make sure that a vehicle which is booked along with required accessories is displayed
4) Latest Brochures, Price List & Packages availability
5) Display screen availability & utilization for Car Configurator',
    '1) Accessory display guideline',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ009',
    'v1-DQ009-002',
    'Facility',
    'Showroom & Accessory Area',
    'Does the dealer display all accessories and the relevant information in a convenient and transparent way?',
    'Facility',
    'Showroom & Accessory Area',
    'Transparency to be maintained by displaying the price details on displayed accessories',
    'Does the dealer display all accessories and the relevant information in a convenient and transparent way?',
    'Direct',
    '3S',
    'Transparency to be maintained by displaying the price details on displayed accessories',
    '*Ensures the convenience of choosing on accessories by guest

*Transparency in decision making by guest for accessories.',
    'Check the following points as a part of Accessory Offering in showroom:
1) Accessories for active Models (Vehicle Sale/ month >=5)  to be showcased in Display Area
2) Placard / Sticker with Accessory Name, Cost & EMI near the Accessories in Display Zone / Area
3) Display of Accessories on all Test Drive Vehicles [>= per car target]
4) Display of Accessories on all vehicles displayed in showroom [>= per car target]
5) Availability of Latest Accessory Brochure & Pricelist in Sales Showroom for all active models (Digital or Printed)
6) Availability of Customized Accessory Package for Active Models [e.g. Basic, Premium, Luxury]
7) Screen @ Dealership to showcase Car Configurator to Customer [TV / Laptop or iPad]',
    '1) Accessory showcase in Exclusive Display Area along with Placard with details
2) Accessory display on test drive & showroom vehicles is must. Incase of display vehicles, accessories can be displaced using stickers which can be easily removed (Considering that display vehicle is changed weekly).
3) Incase of booked vehicle to be displayed, make sure that a vehicle which is booked along with required accessories is displayed
4) Latest Brochures, Price List & Packages availability
5) Display screen availability & utilization for Car Configurator',
    '1) Accessory display guideline',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ009',
    'v1-DQ009-003',
    'Facility',
    'Showroom & Accessory Area',
    'Does the dealer display all accessories and the relevant information in a convenient and transparent way?',
    'Facility',
    'Showroom & Accessory Area',
    'Accessories must be displayed on the display car as per equivalent to the target for particular model.',
    'Does the dealer display all accessories and the relevant information in a convenient and transparent way?',
    'Direct',
    '3S',
    'Accessories must be displayed on the display car as per equivalent to the target for particular model.',
    '*Ensures the convenience of choosing on accessories by guest

*Transparency in decision making by guest for accessories.',
    'Check the following points as a part of Accessory Offering in showroom:
1) Accessories for active Models (Vehicle Sale/ month >=5)  to be showcased in Display Area
2) Placard / Sticker with Accessory Name, Cost & EMI near the Accessories in Display Zone / Area
3) Display of Accessories on all Test Drive Vehicles [>= per car target]
4) Display of Accessories on all vehicles displayed in showroom [>= per car target]
5) Availability of Latest Accessory Brochure & Pricelist in Sales Showroom for all active models (Digital or Printed)
6) Availability of Customized Accessory Package for Active Models [e.g. Basic, Premium, Luxury]
7) Screen @ Dealership to showcase Car Configurator to Customer [TV / Laptop or iPad]',
    '1) Accessory showcase in Exclusive Display Area along with Placard with details
2) Accessory display on test drive & showroom vehicles is must. Incase of display vehicles, accessories can be displaced using stickers which can be easily removed (Considering that display vehicle is changed weekly).
3) Incase of booked vehicle to be displayed, make sure that a vehicle which is booked along with required accessories is displayed
4) Latest Brochures, Price List & Packages availability
5) Display screen availability & utilization for Car Configurator',
    '1) Accessory display guideline',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ010',
    'v1-DQ010-001',
    'Operation [Accessory]',
    'Accessory Area',
    'Does dealer ensure compliance of following Points as a part of Accessory Sales Process?',
    'Operation [Accessory]',
    'Accessory Area',
    'Accessory In-charge Awareness of N+2 Customer deliveries & Accessory to be installed in it? [N = Today] [Reference: Delivery Listing & TGA Planned for the same]',
    'Does dealer ensure compliance of following Points as a part of Accessory Sales Process?',
    'Indirect',
    '3S',
    'Accessory In-charge Awareness of N+2 Customer deliveries & Accessory to be installed in it? [N = Today] [Reference: Delivery Listing & TGA Planned for the same]',
    '* Pitching of accessory sales to all guest at the right time

*Ensures the availability and timely delivery of accessory sales during new car sales',
    '1) Check document from Accessory In-charge where he/she is ensuring Accessory Stock preparation against the Delivery Listing for next month
2) Check for the Customer Communication Process by GEM Sales & Accessory In-charge
3) Conduct Random Audit of Customer Order Files [At least 5 files of each models] for Accessory Order Review by Accessory In-charge & Sales manager
4) Check for the TGA Dashboard Utilization by Accessory In-charge for the Monthly Business Review',
    '1) Delivery List availability at Accessory In-charge
2) Accessory Stock Availability plan for the planned vehicle delivery
3) Customer Order Files
4) TGA Dashboard Access Availability to Accessory In-charge & its utilization',
    '1) TGA Dashboard Overview and Usage guidelines',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ010',
    'v1-DQ010-002',
    'Operation [Accessory]',
    'Accessory Area',
    'Does dealer ensure compliance of following Points as a part of Accessory Sales Process?',
    'Operation [Accessory]',
    'Accessory Area',
    'Availability of methodology to Communicate to Customer about Accessories [What''s App Group, Car Configurator Link sharing with Customer]',
    'Does dealer ensure compliance of following Points as a part of Accessory Sales Process?',
    'Indirect',
    '3S',
    'Availability of methodology to Communicate to Customer about Accessories [What''s App Group, Car Configurator Link sharing with Customer]',
    '* Pitching of accessory sales to all guest at the right time

*Ensures the availability and timely delivery of accessory sales during new car sales',
    '1) Check document from Accessory In-charge where he/she is ensuring Accessory Stock preparation against the Delivery Listing for next month
2) Check for the Customer Communication Process by GEM Sales & Accessory In-charge
3) Conduct Random Audit of Customer Order Files [At least 5 files of each models] for Accessory Order Review by Accessory In-charge & Sales manager
4) Check for the TGA Dashboard Utilization by Accessory In-charge for the Monthly Business Review',
    '1) Delivery List availability at Accessory In-charge
2) Accessory Stock Availability plan for the planned vehicle delivery
3) Customer Order Files
4) TGA Dashboard Access Availability to Accessory In-charge & its utilization',
    '1) TGA Dashboard Overview and Usage guidelines',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ010',
    'v1-DQ010-003',
    'Operation [Accessory]',
    'Accessory Area',
    'Does dealer ensure compliance of following Points as a part of Accessory Sales Process?',
    'Operation [Accessory]',
    'Accessory Area',
    'Availability of Accessory In-charge Signature on Accessories Booking Form [Check Customer Booking Files]',
    'Does dealer ensure compliance of following Points as a part of Accessory Sales Process?',
    'Indirect',
    '3S',
    'Availability of Accessory In-charge Signature on Accessories Booking Form [Check Customer Booking Files]',
    '* Pitching of accessory sales to all guest at the right time

*Ensures the availability and timely delivery of accessory sales during new car sales',
    '1) Check document from Accessory In-charge where he/she is ensuring Accessory Stock preparation against the Delivery Listing for next month
2) Check for the Customer Communication Process by GEM Sales & Accessory In-charge
3) Conduct Random Audit of Customer Order Files [At least 5 files of each models] for Accessory Order Review by Accessory In-charge & Sales manager
4) Check for the TGA Dashboard Utilization by Accessory In-charge for the Monthly Business Review',
    '1) Delivery List availability at Accessory In-charge
2) Accessory Stock Availability plan for the planned vehicle delivery
3) Customer Order Files
4) TGA Dashboard Access Availability to Accessory In-charge & its utilization',
    '1) TGA Dashboard Overview and Usage guidelines',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ010',
    'v1-DQ010-004',
    'Operation [Accessory]',
    'Accessory Area',
    'Does dealer ensure compliance of following Points as a part of Accessory Sales Process?',
    'Operation [Accessory]',
    'Accessory Area',
    'Review of Accessory Order Form in Customer Booking File by Sales Manager on lower than Target or Zero Accessory Order',
    'Does dealer ensure compliance of following Points as a part of Accessory Sales Process?',
    'Indirect',
    '3S',
    'Review of Accessory Order Form in Customer Booking File by Sales Manager on lower than Target or Zero Accessory Order',
    '* Pitching of accessory sales to all guest at the right time

*Ensures the availability and timely delivery of accessory sales during new car sales',
    '1) Check document from Accessory In-charge where he/she is ensuring Accessory Stock preparation against the Delivery Listing for next month
2) Check for the Customer Communication Process by GEM Sales & Accessory In-charge
3) Conduct Random Audit of Customer Order Files [At least 5 files of each models] for Accessory Order Review by Accessory In-charge & Sales manager
4) Check for the TGA Dashboard Utilization by Accessory In-charge for the Monthly Business Review',
    '1) Delivery List availability at Accessory In-charge
2) Accessory Stock Availability plan for the planned vehicle delivery
3) Customer Order Files
4) TGA Dashboard Access Availability to Accessory In-charge & its utilization',
    '1) TGA Dashboard Overview and Usage guidelines',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ010',
    'v1-DQ010-005',
    'Operation [Accessory]',
    'Accessory Area',
    'Does dealer ensure compliance of following Points as a part of Accessory Sales Process?',
    'Operation [Accessory]',
    'Accessory Area',
    'Utilization of TGA Dashboard to Review the Accessory Performance periodically?',
    'Does dealer ensure compliance of following Points as a part of Accessory Sales Process?',
    'Indirect',
    '3S',
    'Utilization of TGA Dashboard to Review the Accessory Performance periodically?',
    '* Pitching of accessory sales to all guest at the right time

*Ensures the availability and timely delivery of accessory sales during new car sales',
    '1) Check document from Accessory In-charge where he/she is ensuring Accessory Stock preparation against the Delivery Listing for next month
2) Check for the Customer Communication Process by GEM Sales & Accessory In-charge
3) Conduct Random Audit of Customer Order Files [At least 5 files of each models] for Accessory Order Review by Accessory In-charge & Sales manager
4) Check for the TGA Dashboard Utilization by Accessory In-charge for the Monthly Business Review',
    '1) Delivery List availability at Accessory In-charge
2) Accessory Stock Availability plan for the planned vehicle delivery
3) Customer Order Files
4) TGA Dashboard Access Availability to Accessory In-charge & its utilization',
    '1) TGA Dashboard Overview and Usage guidelines',
    false,
    '["Accessory"]'::jsonb,
    'active'
  );

INSERT INTO audit_checklist_master (
  checklist_code,
  version,
  section,
  area,
  chapter,
  classification,
  location_aspect,
  evaluation_question,
  evaluation_parameter,
  guest_experience_impact,
  facility_type,
  question,
  purpose,
  checking_method,
  additional_info,
  sop_reference,
  evidence_required,
  applicable_departments,
  status
) VALUES
(
    'DQ011',
    'v1-DQ011-001',
    'Operation [Accessory]',
    'Accessory Area / Stock area',
    'Does dealer ensure compliance of following points as a part of Accessory Demand & Supply Management?',
    'Operation [Accessory]',
    'Accessory Area / Stock area',
    'Maintaining 15 Days of Accessories Stock at Dealership to avoid customer back order',
    'Does dealer ensure compliance of following points as a part of Accessory Demand & Supply Management?',
    'Direct',
    '3S',
    'Maintaining 15 Days of Accessories Stock at Dealership to avoid customer back order',
    '*Ensure availability of accessory in the right quantity.
*Reduce business loss due to the dead stock',
    '1) Check Accessory Stock Report through Parts Manager at Dealer
2) Check the Accessory wise ordering trend against the available stock to check excess or Back Order situation
3) Check the Dead Stock Ageing Report through Parts Manager
4) Check actual document for the Dead Stock Liquidation Scheme',
    '1) Accessory Stock Report
2) Accessory wise Ordering Trend
3) Gather the Dead Stock Ageing Report through Parts Manager
4) Actual document checking for the Dead Stock Liquidation Scheme',
    '1) Accessory Stock guidelines',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ011',
    'v1-DQ011-002',
    'Operation [Accessory]',
    'Accessory Area / Stock area',
    'Does dealer ensure compliance of following points as a part of Accessory Demand & Supply Management?',
    'Operation [Accessory]',
    'Accessory Area / Stock area',
    'Adhering to Accessory Stock Order Logic based on Intstallation Ratio (IR% & Vehicle Rundown to maintain 15 Days of Stock)',
    'Does dealer ensure compliance of following points as a part of Accessory Demand & Supply Management?',
    'Direct',
    '3S',
    'Adhering to Accessory Stock Order Logic based on Intstallation Ratio (IR% & Vehicle Rundown to maintain 15 Days of Stock)',
    '*Ensure availability of accessory in the right quantity.
*Reduce business loss due to the dead stock',
    '1) Check Accessory Stock Report through Parts Manager at Dealer
2) Check the Accessory wise ordering trend against the available stock to check excess or Back Order situation
3) Check the Dead Stock Ageing Report through Parts Manager
4) Check actual document for the Dead Stock Liquidation Scheme',
    '1) Accessory Stock Report
2) Accessory wise Ordering Trend
3) Gather the Dead Stock Ageing Report through Parts Manager
4) Actual document checking for the Dead Stock Liquidation Scheme',
    '1) Accessory Stock guidelines',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ011',
    'v1-DQ011-003',
    'Operation [Accessory]',
    'Accessory Area / Stock area',
    'Does dealer ensure compliance of following points as a part of Accessory Demand & Supply Management?',
    'Operation [Accessory]',
    'Accessory Area / Stock area',
    'Awareness of Accessory Dead Stock information to Accessory In charge for the Runout Models',
    'Does dealer ensure compliance of following points as a part of Accessory Demand & Supply Management?',
    'Direct',
    '3S',
    'Awareness of Accessory Dead Stock information to Accessory In charge for the Runout Models',
    '*Ensure availability of accessory in the right quantity.
*Reduce business loss due to the dead stock',
    '1) Check Accessory Stock Report through Parts Manager at Dealer
2) Check the Accessory wise ordering trend against the available stock to check excess or Back Order situation
3) Check the Dead Stock Ageing Report through Parts Manager
4) Check actual document for the Dead Stock Liquidation Scheme',
    '1) Accessory Stock Report
2) Accessory wise Ordering Trend
3) Gather the Dead Stock Ageing Report through Parts Manager
4) Actual document checking for the Dead Stock Liquidation Scheme',
    '1) Accessory Stock guidelines',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ011',
    'v1-DQ011-004',
    'Operation [Accessory]',
    'Accessory Area / Stock area',
    'Does dealer ensure compliance of following points as a part of Accessory Demand & Supply Management?',
    'Operation [Accessory]',
    'Accessory Area / Stock area',
    'Availability of Process / scheme to promote accessory / Liquidate Dead Stock through UIO Customers',
    'Does dealer ensure compliance of following points as a part of Accessory Demand & Supply Management?',
    'Direct',
    '3S',
    'Availability of Process / scheme to promote accessory / Liquidate Dead Stock through UIO Customers',
    '*Ensure availability of accessory in the right quantity.
*Reduce business loss due to the dead stock',
    '1) Check Accessory Stock Report through Parts Manager at Dealer
2) Check the Accessory wise ordering trend against the available stock to check excess or Back Order situation
3) Check the Dead Stock Ageing Report through Parts Manager
4) Check actual document for the Dead Stock Liquidation Scheme',
    '1) Accessory Stock Report
2) Accessory wise Ordering Trend
3) Gather the Dead Stock Ageing Report through Parts Manager
4) Actual document checking for the Dead Stock Liquidation Scheme',
    '1) Accessory Stock guidelines',
    false,
    '["Accessory"]'::jsonb,
    'active'
  ),
(
    'DQ012',
    'v1-DQ012-001',
    'Operation [Sales]',
    'Showroom',
    '[Initial Contact & Guest care]
Does Customers are greeted and taken care of like the guests at home [HTGE] and GEM-Sales attends the guest Immediately and assists in purchase process?',
    'Operation [Sales]',
    'Showroom',
    'Guest were greeted warmly at all touchpoints during entrance (Security, Reception, GEM Sales',
    '[Initial Contact & Guest care]
Does Customers are greeted and taken care of like the guests at home [HTGE] and GEM-Sales attends the guest Immediately and assists in purchase process?',
    'Direct',
    '3S',
    'Guest were greeted warmly at all touchpoints during entrance (Security, Reception, GEM Sales',
    '*Ensure guest feel at home and invited during the visit to showroom',
    '1) Check guests are greeted by security at the main gate, assisted in parking the car and escorted to show room / Service reception.
2) The Frontline team greets the guest with Namaste (GEM, SH/LIC, U-trust team, support team and all the members come in contact with Guest)
3) Offered the seat, preferred beverages / snacks at right time & kept engaged all the time
4) Guests preferences are captured / updated in the system (eCRB)
5) GEM Sales attends the guest with in 2 mins from the arrival, introduce him/herself and takes care of the guest comfort (seating, beverage, language preference)
6) GEM-Sales business cared / e-card, enquiry Docket, e-broachers are provided to Guest.
7) First time buyers are introduced to Toyota Brand and Dealer (Facility tour if guest interested)',
    '1) GEM sales & Showroom host are in the proper business attire (well groomed, wearing name badges)
2) GEM-sales polite, confident & professional during the interaction with the guests',
    '1) HTGE Elements (Refer Seamless SOP)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ012',
    'v1-DQ012-002',
    'Operation [Sales]',
    'Showroom',
    '[Initial Contact & Guest care]
Does Customers are greeted and taken care of like the guests at home [HTGE] and GEM-Sales attends the guest Immediately and assists in purchase process?',
    'Operation [Sales]',
    'Showroom',
    'Guests are offered with comfortable seating, beverages, snacks and preferences are captured',
    '[Initial Contact & Guest care]
Does Customers are greeted and taken care of like the guests at home [HTGE] and GEM-Sales attends the guest Immediately and assists in purchase process?',
    'Direct',
    '3S',
    'Guests are offered with comfortable seating, beverages, snacks and preferences are captured',
    '*Ensure guest feel at home and invited during the visit to showroom',
    '1) Check guests are greeted by security at the main gate, assisted in parking the car and escorted to show room / Service reception.
2) The Frontline team greets the guest with Namaste (GEM, SH/LIC, U-trust team, support team and all the members come in contact with Guest)
3) Offered the seat, preferred beverages / snacks at right time & kept engaged all the time
4) Guests preferences are captured / updated in the system (eCRB)
5) GEM Sales attends the guest with in 2 mins from the arrival, introduce him/herself and takes care of the guest comfort (seating, beverage, language preference)
6) GEM-Sales business cared / e-card, enquiry Docket, e-broachers are provided to Guest.
7) First time buyers are introduced to Toyota Brand and Dealer (Facility tour if guest interested)',
    '1) GEM sales & Showroom host are in the proper business attire (well groomed, wearing name badges)
2) GEM-sales polite, confident & professional during the interaction with the guests',
    '1) HTGE Elements (Refer Seamless SOP)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ012',
    'v1-DQ012-003',
    'Operation [Sales]',
    'Showroom',
    '[Initial Contact & Guest care]
Does Customers are greeted and taken care of like the guests at home [HTGE] and GEM-Sales attends the guest Immediately and assists in purchase process?',
    'Operation [Sales]',
    'Showroom',
    'GEM sales greet and introduce himself with business card and provide all necessary information to guest. And first time buyers are introduced to Toyota Brand and Dealer',
    '[Initial Contact & Guest care]
Does Customers are greeted and taken care of like the guests at home [HTGE] and GEM-Sales attends the guest Immediately and assists in purchase process?',
    'Direct',
    '3S',
    'GEM sales greet and introduce himself with business card and provide all necessary information to guest. And first time buyers are introduced to Toyota Brand and Dealer',
    '*Ensure guest feel at home and invited during the visit to showroom',
    '1) Check guests are greeted by security at the main gate, assisted in parking the car and escorted to show room / Service reception.
2) The Frontline team greets the guest with Namaste (GEM, SH/LIC, U-trust team, support team and all the members come in contact with Guest)
3) Offered the seat, preferred beverages / snacks at right time & kept engaged all the time
4) Guests preferences are captured / updated in the system (eCRB)
5) GEM Sales attends the guest with in 2 mins from the arrival, introduce him/herself and takes care of the guest comfort (seating, beverage, language preference)
6) GEM-Sales business cared / e-card, enquiry Docket, e-broachers are provided to Guest.
7) First time buyers are introduced to Toyota Brand and Dealer (Facility tour if guest interested)',
    '1) GEM sales & Showroom host are in the proper business attire (well groomed, wearing name badges)
2) GEM-sales polite, confident & professional during the interaction with the guests',
    '1) HTGE Elements (Refer Seamless SOP)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ013',
    'v1-DQ013-001',
    'Operation [Sales]',
    'Showroom',
    '[New car Sales Process]
Does dealer GEM sales follows the right sales SOP as per the guest needs?',
    'Operation [Sales]',
    'Showroom',
    'GEM-Sales follow the NAB* process, understand the guest needs and suggests the right car to purchase. *NAB - Need Authority Budget',
    '[New car Sales Process]
Does dealer GEM sales follows the right sales SOP as per the guest needs?',
    'Direct',
    '3S',
    'GEM-Sales follow the NAB* process, understand the guest needs and suggests the right car to purchase. *NAB - Need Authority Budget',
    '*Ensuring the right and sufficient requirement is gathered from guest to pitch right product',
    'Check if GEM-Sales performs the following actions
1) Asks right questions to identify the Need-Authority-Budget of the enquiry.
2) Notes relevant details in the right sections of Profile in iPad (Demand structure, model etc.)
3) Suggests the car model (suiting enquiry''s needs) and get an agreement.
4) Presents / explains selected model to the guest, using 6 position walk-around / FOR YOU & FAB techniques
5) Utilizes the i-PAD / Kiosk to explain the car features (Toyota car viewer)
6) Offers Test Drive (of selected model) and updates the test drive result / feedback details in i-PAD
7) Explains the key features, controls, comfort, safety feature of the car before & during the test drive as it suits',
    '1) Check Profile in iPad filled by the SC post discussion with the enquiry
2) Download Enquiry Management report from TL''s LAKSHYA Login and evaluate fields filled in by SC
3) Incase the test-drive could not be offered at dealership, option of test drive at home is offered
4) Test drive route options / details should be available and the right route is offered based on the guest usage pattern',
    '1) Sales SOP (Laksha Portal)
2) NABing Process / Questionnaire Annexure
3) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ013',
    'v1-DQ013-002',
    'Operation [Sales]',
    'Showroom',
    '[New car Sales Process]
Does dealer GEM sales follows the right sales SOP as per the guest needs?',
    'Operation [Sales]',
    'Showroom',
    'GEM-sales Provides the demo & test-drive of the car to the full satisfaction of the guest',
    '[New car Sales Process]
Does dealer GEM sales follows the right sales SOP as per the guest needs?',
    'Direct',
    '3S',
    'GEM-sales Provides the demo & test-drive of the car to the full satisfaction of the guest',
    '*Ensuring the right and sufficient requirement is gathered from guest to pitch right product',
    'Check if GEM-Sales performs the following actions
1) Asks right questions to identify the Need-Authority-Budget of the enquiry.
2) Notes relevant details in the right sections of Profile in iPad (Demand structure, model etc.)
3) Suggests the car model (suiting enquiry''s needs) and get an agreement.
4) Presents / explains selected model to the guest, using 6 position walk-around / FOR YOU & FAB techniques
5) Utilizes the i-PAD / Kiosk to explain the car features (Toyota car viewer)
6) Offers Test Drive (of selected model) and updates the test drive result / feedback details in i-PAD
7) Explains the key features, controls, comfort, safety feature of the car before & during the test drive as it suits',
    '1) Check Profile in iPad filled by the SC post discussion with the enquiry
2) Download Enquiry Management report from TL''s LAKSHYA Login and evaluate fields filled in by SC
3) Incase the test-drive could not be offered at dealership, option of test drive at home is offered
4) Test drive route options / details should be available and the right route is offered based on the guest usage pattern',
    '1) Sales SOP (Laksha Portal)
2) NABing Process / Questionnaire Annexure
3) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ013',
    'v1-DQ013-003',
    'Operation [Sales]',
    'Showroom',
    '[New car Sales Process]
Does dealer GEM sales follows the right sales SOP as per the guest needs?',
    'Operation [Sales]',
    'Showroom',
    'GEM-Sales utilized necessary documents/systems (i-PAD or KIOSK to explain the product feature)',
    '[New car Sales Process]
Does dealer GEM sales follows the right sales SOP as per the guest needs?',
    'Direct',
    '3S',
    'GEM-Sales utilized necessary documents/systems (i-PAD or KIOSK to explain the product feature)',
    '*Ensuring the right and sufficient requirement is gathered from guest to pitch right product',
    'Check if GEM-Sales performs the following actions
1) Asks right questions to identify the Need-Authority-Budget of the enquiry.
2) Notes relevant details in the right sections of Profile in iPad (Demand structure, model etc.)
3) Suggests the car model (suiting enquiry''s needs) and get an agreement.
4) Presents / explains selected model to the guest, using 6 position walk-around / FOR YOU & FAB techniques
5) Utilizes the i-PAD / Kiosk to explain the car features (Toyota car viewer)
6) Offers Test Drive (of selected model) and updates the test drive result / feedback details in i-PAD
7) Explains the key features, controls, comfort, safety feature of the car before & during the test drive as it suits',
    '1) Check Profile in iPad filled by the SC post discussion with the enquiry
2) Download Enquiry Management report from TL''s LAKSHYA Login and evaluate fields filled in by SC
3) Incase the test-drive could not be offered at dealership, option of test drive at home is offered
4) Test drive route options / details should be available and the right route is offered based on the guest usage pattern',
    '1) Sales SOP (Laksha Portal)
2) NABing Process / Questionnaire Annexure
3) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ014',
    'v1-DQ014-001',
    'Operation [Seamless]',
    'Showroom',
    '[Vehicle Exchange]
Does GEM-Sales understands the guest requirement for exchange and assist the guest in exchanging the used car?',
    'Operation [Seamless]',
    'Showroom',
    'GEM-Sales capture existing car details and exchange interest in the system while creating enquiry',
    '[Vehicle Exchange]
Does GEM-Sales understands the guest requirement for exchange and assist the guest in exchanging the used car?',
    'Direct',
    '3S',
    'GEM-Sales capture existing car details and exchange interest in the system while creating enquiry',
    '*Ensuring the one-stop solution for guest convenience and reducing financial burden on guest.',
    'Check if GEM-Sales perform the following SOP incase of exchange 
1) Capture the existing car details and interest for exchange and 
2) For exchange, update demand structure as ''Replacement'' while creating enquiry in system
3) Share the information with Procurement officer through e-CRB i-PAD and requests for valuation of vehicle
4) GEM-Sales along with PO invites guest to join valuation process
5) Procurement Officer (PO) conducts valuation and share price with GEM-Sales through system 
6) GEM sales keeps the guest engaged during vehicle valuation based on guest preference (Join the valuation or provide demo / test drive of New car)',
    '1) Use TKM provided check sheet for valuation process
2) GEM sales will be contact point between the guest & Procurement Officer (PO). PO will not discuss the price information with guest directly',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ014',
    'v1-DQ014-002',
    'Operation [Seamless]',
    'Showroom',
    '[Vehicle Exchange]
Does GEM-Sales understands the guest requirement for exchange and assist the guest in exchanging the used car?',
    'Operation [Seamless]',
    'Showroom',
    'GEM-Sales utilizes system (e-CRB i-PAD to inform procurement officer and request for valuation of vehicle.)',
    '[Vehicle Exchange]
Does GEM-Sales understands the guest requirement for exchange and assist the guest in exchanging the used car?',
    'Direct',
    '3S',
    'GEM-Sales utilizes system (e-CRB i-PAD to inform procurement officer and request for valuation of vehicle.)',
    '*Ensuring the one-stop solution for guest convenience and reducing financial burden on guest.',
    'Check if GEM-Sales perform the following SOP incase of exchange 
1) Capture the existing car details and interest for exchange and 
2) For exchange, update demand structure as ''Replacement'' while creating enquiry in system
3) Share the information with Procurement officer through e-CRB i-PAD and requests for valuation of vehicle
4) GEM-Sales along with PO invites guest to join valuation process
5) Procurement Officer (PO) conducts valuation and share price with GEM-Sales through system 
6) GEM sales keeps the guest engaged during vehicle valuation based on guest preference (Join the valuation or provide demo / test drive of New car)',
    '1) Use TKM provided check sheet for valuation process
2) GEM sales will be contact point between the guest & Procurement Officer (PO). PO will not discuss the price information with guest directly',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ014',
    'v1-DQ014-003',
    'Operation [Seamless]',
    'Showroom',
    '[Vehicle Exchange]
Does GEM-Sales understands the guest requirement for exchange and assist the guest in exchanging the used car?',
    'Operation [Seamless]',
    'Showroom',
    'GEM-Sales keep engaging the guest during valuation based on guest preferences and receives the valuation details through system by PO (Procurement Officer',
    '[Vehicle Exchange]
Does GEM-Sales understands the guest requirement for exchange and assist the guest in exchanging the used car?',
    'Direct',
    '3S',
    'GEM-Sales keep engaging the guest during valuation based on guest preferences and receives the valuation details through system by PO (Procurement Officer',
    '*Ensuring the one-stop solution for guest convenience and reducing financial burden on guest.',
    'Check if GEM-Sales perform the following SOP incase of exchange 
1) Capture the existing car details and interest for exchange and 
2) For exchange, update demand structure as ''Replacement'' while creating enquiry in system
3) Share the information with Procurement officer through e-CRB i-PAD and requests for valuation of vehicle
4) GEM-Sales along with PO invites guest to join valuation process
5) Procurement Officer (PO) conducts valuation and share price with GEM-Sales through system 
6) GEM sales keeps the guest engaged during vehicle valuation based on guest preference (Join the valuation or provide demo / test drive of New car)',
    '1) Use TKM provided check sheet for valuation process
2) GEM sales will be contact point between the guest & Procurement Officer (PO). PO will not discuss the price information with guest directly',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ015',
    'v1-DQ015-001',
    'Operation [Seamless]',
    'Showroom',
    '[Value Chain]
Does GEM-Sales, as a single Point of contact, explain the value chain product and assist to choose the suitable products?',
    'Operation [Seamless]',
    'Showroom',
    'GEM-Sales explain and offers accessories, Insurance, Extended Warranty, AMC and Finance options by self utilizing the digital tool (eCRB, TSA, Kiosk, TCV',
    '[Value Chain]
Does GEM-Sales, as a single Point of contact, explain the value chain product and assist to choose the suitable products?',
    'Direct',
    '3S',
    'GEM-Sales explain and offers accessories, Insurance, Extended Warranty, AMC and Finance options by self utilizing the digital tool (eCRB, TSA, Kiosk, TCV',
    '*Ensuring the one-stop solution for guest convenience and offers the best value & products as per guest need.',
    '1) GEM-Sales, as single point of contact, explains the value chain product - Accessories, Insurance, Extended Warranty / AMC and Finance options ( Do not leave the guest in the hands of value chain PIC)
2) Utilizes digital tool (eCRB, TSA, Kiosk, TCV) for explanation of value chain products
3) Based on Guest Consent, GEM-sales updates the price of selected value chain products and calculate total value and the approximate EMI using the EMI calculator',
    '1) Value chain in-charge supports the GEM-sales whenever required',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ015',
    'v1-DQ015-002',
    'Operation [Seamless]',
    'Showroom',
    '[Value Chain]
Does GEM-Sales, as a single Point of contact, explain the value chain product and assist to choose the suitable products?',
    'Operation [Seamless]',
    'Showroom',
    'GEM-sales updates the price of Value chain products and calculate total value and share the approximate EMI using the EMI calculator to guest.',
    '[Value Chain]
Does GEM-Sales, as a single Point of contact, explain the value chain product and assist to choose the suitable products?',
    'Direct',
    '3S',
    'GEM-sales updates the price of Value chain products and calculate total value and share the approximate EMI using the EMI calculator to guest.',
    '*Ensuring the one-stop solution for guest convenience and offers the best value & products as per guest need.',
    '1) GEM-Sales, as single point of contact, explains the value chain product - Accessories, Insurance, Extended Warranty / AMC and Finance options ( Do not leave the guest in the hands of value chain PIC)
2) Utilizes digital tool (eCRB, TSA, Kiosk, TCV) for explanation of value chain products
3) Based on Guest Consent, GEM-sales updates the price of selected value chain products and calculate total value and the approximate EMI using the EMI calculator',
    '1) Value chain in-charge supports the GEM-sales whenever required',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ016',
    'v1-DQ016-001',
    'Operation [Sales]',
    'Showroom',
    '[Vehicle Booking]
Does GEM-sales confirm the booking details and informs the tentative delivery date range based on the MDDP?',
    'Operation [Sales]',
    'Showroom',
    'GEM-Sales confimsmodel, suffic, color of car and tentative delivery date using waiting period matrix or MDDP (Confirm with SSOPI in-charge',
    '[Vehicle Booking]
Does GEM-sales confirm the booking details and informs the tentative delivery date range based on the MDDP?',
    'Direct',
    '3S',
    'GEM-Sales confimsmodel, suffic, color of car and tentative delivery date using waiting period matrix or MDDP (Confirm with SSOPI in-charge',
    '*Ensuring guest receives all the relevant and right information during the vehicle booking.',
    '1) Discusses and confirms model, suffix and color of the car
2) Explains the tentative delivery date range, for the selected model/suffix, using the waiting period matrix or MDDP (confirm with SSOPI In-charge)
3) Introduces the Sales Docket (TKM Recommended Welcome Kit) and fills the relevant details. 
4) Reconfirms the booking details (model, suffix, color, value chain products, finance scheme, delivery date) & fills the relevant details in the Order Booking Form
5) Explain the registration (RTO) & loan approval process and collects the relevant documents from the guest (offer doorstep service, if documents are not available at the time of booking)
6) Updates the order booking form & explains the booking details, get guest''s signature on order booking form and handover the welcome docket to guest.
7) Get the booking form validated and approved by SM and submit the form & relevant documents to backend team',
    '1) MDDP Plan : Monthly Daily Dispatch Plan
2) Waiting period matrix (Latest Communication)
3) Welcome Kit (TKM Standard)
4) Order Booking Form',
    '1) Sales SOP (Laksha Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ016',
    'v1-DQ016-002',
    'Operation [Sales]',
    'Showroom',
    '[Vehicle Booking]
Does GEM-sales confirm the booking details and informs the tentative delivery date range based on the MDDP?',
    'Operation [Sales]',
    'Showroom',
    'GEM-Sales fill relevant details in TKM recommended Welcome Kit and reconfirm booking details by filling the details in the Order Booking Form.',
    '[Vehicle Booking]
Does GEM-sales confirm the booking details and informs the tentative delivery date range based on the MDDP?',
    'Direct',
    '3S',
    'GEM-Sales fill relevant details in TKM recommended Welcome Kit and reconfirm booking details by filling the details in the Order Booking Form.',
    '*Ensuring guest receives all the relevant and right information during the vehicle booking.',
    '1) Discusses and confirms model, suffix and color of the car
2) Explains the tentative delivery date range, for the selected model/suffix, using the waiting period matrix or MDDP (confirm with SSOPI In-charge)
3) Introduces the Sales Docket (TKM Recommended Welcome Kit) and fills the relevant details. 
4) Reconfirms the booking details (model, suffix, color, value chain products, finance scheme, delivery date) & fills the relevant details in the Order Booking Form
5) Explain the registration (RTO) & loan approval process and collects the relevant documents from the guest (offer doorstep service, if documents are not available at the time of booking)
6) Updates the order booking form & explains the booking details, get guest''s signature on order booking form and handover the welcome docket to guest.
7) Get the booking form validated and approved by SM and submit the form & relevant documents to backend team',
    '1) MDDP Plan : Monthly Daily Dispatch Plan
2) Waiting period matrix (Latest Communication)
3) Welcome Kit (TKM Standard)
4) Order Booking Form',
    '1) Sales SOP (Laksha Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ016',
    'v1-DQ016-003',
    'Operation [Sales]',
    'Showroom',
    '[Vehicle Booking]
Does GEM-sales confirm the booking details and informs the tentative delivery date range based on the MDDP?',
    'Operation [Sales]',
    'Showroom',
    'GEM-Sales explains the registration (RTO & loan approval process and collects relevant document and take approval from guest in the Order booking form.)',
    '[Vehicle Booking]
Does GEM-sales confirm the booking details and informs the tentative delivery date range based on the MDDP?',
    'Direct',
    '3S',
    'GEM-Sales explains the registration (RTO & loan approval process and collects relevant document and take approval from guest in the Order booking form.)',
    '*Ensuring guest receives all the relevant and right information during the vehicle booking.',
    '1) Discusses and confirms model, suffix and color of the car
2) Explains the tentative delivery date range, for the selected model/suffix, using the waiting period matrix or MDDP (confirm with SSOPI In-charge)
3) Introduces the Sales Docket (TKM Recommended Welcome Kit) and fills the relevant details. 
4) Reconfirms the booking details (model, suffix, color, value chain products, finance scheme, delivery date) & fills the relevant details in the Order Booking Form
5) Explain the registration (RTO) & loan approval process and collects the relevant documents from the guest (offer doorstep service, if documents are not available at the time of booking)
6) Updates the order booking form & explains the booking details, get guest''s signature on order booking form and handover the welcome docket to guest.
7) Get the booking form validated and approved by SM and submit the form & relevant documents to backend team',
    '1) MDDP Plan : Monthly Daily Dispatch Plan
2) Waiting period matrix (Latest Communication)
3) Welcome Kit (TKM Standard)
4) Order Booking Form',
    '1) Sales SOP (Laksha Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ016',
    'v1-DQ016-004',
    'Operation [Sales]',
    'Showroom',
    '[Vehicle Booking]
Does GEM-sales confirm the booking details and informs the tentative delivery date range based on the MDDP?',
    'Operation [Sales]',
    'Showroom',
    'GEM-Sales handover the welcome docket to guest and take approval from Sales manager in Order Booking form and submit to backend team.',
    '[Vehicle Booking]
Does GEM-sales confirm the booking details and informs the tentative delivery date range based on the MDDP?',
    'Direct',
    '3S',
    'GEM-Sales handover the welcome docket to guest and take approval from Sales manager in Order Booking form and submit to backend team.',
    '*Ensuring guest receives all the relevant and right information during the vehicle booking.',
    '1) Discusses and confirms model, suffix and color of the car
2) Explains the tentative delivery date range, for the selected model/suffix, using the waiting period matrix or MDDP (confirm with SSOPI In-charge)
3) Introduces the Sales Docket (TKM Recommended Welcome Kit) and fills the relevant details. 
4) Reconfirms the booking details (model, suffix, color, value chain products, finance scheme, delivery date) & fills the relevant details in the Order Booking Form
5) Explain the registration (RTO) & loan approval process and collects the relevant documents from the guest (offer doorstep service, if documents are not available at the time of booking)
6) Updates the order booking form & explains the booking details, get guest''s signature on order booking form and handover the welcome docket to guest.
7) Get the booking form validated and approved by SM and submit the form & relevant documents to backend team',
    '1) MDDP Plan : Monthly Daily Dispatch Plan
2) Waiting period matrix (Latest Communication)
3) Welcome Kit (TKM Standard)
4) Order Booking Form',
    '1) Sales SOP (Laksha Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ017',
    'v1-DQ017-001',
    'Operation [Sales]',
    'Sales Back Office',
    '[Waiting Guest Engagement]
Does GEM-Sales keep the waiting guest (Booking to delivery) engaged with frequent communication?',
    'Operation [Sales]',
    'Sales Back Office',
    'GEM-Sales engage the guest with frequent communication as per the standard set by distributor.',
    '[Waiting Guest Engagement]
Does GEM-Sales keep the waiting guest (Booking to delivery) engaged with frequent communication?',
    'Direct',
    '3S',
    'GEM-Sales engage the guest with frequent communication as per the standard set by distributor.',
    '*Ensuring guest are engaged continuously to avoid and distress and inconvenience during the waiting period.',
    '1) GEM-Sales keep the waiting guest (Booking to delivery) engaged with frequent communication as per the standards set by TKM (D&S team)
2) Status of the vehicle allocation, updated delivery date, status of the loan processing is informed to the guest at the regular interval
3) Change in the delivery date is informed to the guest immediately with the reason for change and update the revised delivery date in the relevant document with guest approval',
    '1) Refer Waiting guest engagement guideline
2) Check the communication sent to waiting guest (WhatsApp, email)',
    '1) Sales SOP (Lakshya Portal)
2) Waiting Guest Engagement guideline',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ017',
    'v1-DQ017-002',
    'Operation [Sales]',
    'Sales Back Office',
    '[Waiting Guest Engagement]
Does GEM-Sales keep the waiting guest (Booking to delivery) engaged with frequent communication?',
    'Operation [Sales]',
    'Sales Back Office',
    'GEM-Sales communicate the status of vehicle, updated delivery date with reason for change and ensure guests are informed.',
    '[Waiting Guest Engagement]
Does GEM-Sales keep the waiting guest (Booking to delivery) engaged with frequent communication?',
    'Direct',
    '3S',
    'GEM-Sales communicate the status of vehicle, updated delivery date with reason for change and ensure guests are informed.',
    '*Ensuring guest are engaged continuously to avoid and distress and inconvenience during the waiting period.',
    '1) GEM-Sales keep the waiting guest (Booking to delivery) engaged with frequent communication as per the standards set by TKM (D&S team)
2) Status of the vehicle allocation, updated delivery date, status of the loan processing is informed to the guest at the regular interval
3) Change in the delivery date is informed to the guest immediately with the reason for change and update the revised delivery date in the relevant document with guest approval',
    '1) Refer Waiting guest engagement guideline
2) Check the communication sent to waiting guest (WhatsApp, email)',
    '1) Sales SOP (Lakshya Portal)
2) Waiting Guest Engagement guideline',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ018',
    'v1-DQ018-001',
    'Operation [Sales]',
    'Showroom',
    '[Vehicle Delivery Preparation]
Does GEM-Sales check the readiness of vehicle, related documents and inform the guest about the delivery?',
    'Operation [Sales]',
    'Showroom',
    'Customer file is updated with all required documents (Order Booking Form, TGA booking forrm & receipts, Finance, Insurance, Extended warranty, Service Pack, Registration related',
    '[Vehicle Delivery Preparation]
Does GEM-Sales check the readiness of vehicle, related documents and inform the guest about the delivery?',
    'Direct',
    '3S',
    'Customer file is updated with all required documents (Order Booking Form, TGA booking forrm & receipts, Finance, Insurance, Extended warranty, Service Pack, Registration related',
    '*Ensuring the thorough readiness of vehicle, documents before delivery to avoid any inconvenience to guest.',
    '1) Check all the documents in the Customer File & get it updated in case of any discrepancies:
- Order Booking Form, TGA booking form & Receipts
- Finance, Insurance, Extended Warranty and Service Value Pack related documents 
- Registration related documents
2) Confirm status of vehicle readiness - Vehicle condition, VDQI completion, TGA installation, Fast-tag, TGloss
3) Call the guest on N-1 day (N is planned delivery date) and confirm time / location of delivery ceremony (dealership or home) and Special ceremony requirement
4) Informs Delivery In-charge about the delivery requirement (Home delivery, special ceremony etc.)
5) Prepare the delivery kit',
    '1) Check for the availability of delivery schedule

2) Check for the readiness of following documents
> RTO documents
> Loan documents
> Invoice 
> Insurance copy
> Order form

Note : 
VDS : Vehicle Detailing Services,VDQI : Vehicle Delivery Quality Inspection, TGloss : Toyota Gloss Studio',
    '1) Sales SOP (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ018',
    'v1-DQ018-002',
    'Operation [Sales]',
    'Showroom',
    '[Vehicle Delivery Preparation]
Does GEM-Sales check the readiness of vehicle, related documents and inform the guest about the delivery?',
    'Operation [Sales]',
    'Showroom',
    'Ensure vehicle readiness (Vehicle condition, VDQI completion, TGA installation, Fast tag, TGloss etc..',
    '[Vehicle Delivery Preparation]
Does GEM-Sales check the readiness of vehicle, related documents and inform the guest about the delivery?',
    'Direct',
    '3S',
    'Ensure vehicle readiness (Vehicle condition, VDQI completion, TGA installation, Fast tag, TGloss etc..',
    '*Ensuring the thorough readiness of vehicle, documents before delivery to avoid any inconvenience to guest.',
    '1) Check all the documents in the Customer File & get it updated in case of any discrepancies:
- Order Booking Form, TGA booking form & Receipts
- Finance, Insurance, Extended Warranty and Service Value Pack related documents 
- Registration related documents
2) Confirm status of vehicle readiness - Vehicle condition, VDQI completion, TGA installation, Fast-tag, TGloss
3) Call the guest on N-1 day (N is planned delivery date) and confirm time / location of delivery ceremony (dealership or home) and Special ceremony requirement
4) Informs Delivery In-charge about the delivery requirement (Home delivery, special ceremony etc.)
5) Prepare the delivery kit',
    '1) Check for the availability of delivery schedule

2) Check for the readiness of following documents
> RTO documents
> Loan documents
> Invoice 
> Insurance copy
> Order form

Note : 
VDS : Vehicle Detailing Services,VDQI : Vehicle Delivery Quality Inspection, TGloss : Toyota Gloss Studio',
    '1) Sales SOP (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ018',
    'v1-DQ018-003',
    'Operation [Sales]',
    'Showroom',
    '[Vehicle Delivery Preparation]
Does GEM-Sales check the readiness of vehicle, related documents and inform the guest about the delivery?',
    'Operation [Sales]',
    'Showroom',
    'GEM-Sales informs the guest and fix the delivery date & time on N-1 day and informs delivery in-charge about the delivery requirement.',
    '[Vehicle Delivery Preparation]
Does GEM-Sales check the readiness of vehicle, related documents and inform the guest about the delivery?',
    'Direct',
    '3S',
    'GEM-Sales informs the guest and fix the delivery date & time on N-1 day and informs delivery in-charge about the delivery requirement.',
    '*Ensuring the thorough readiness of vehicle, documents before delivery to avoid any inconvenience to guest.',
    '1) Check all the documents in the Customer File & get it updated in case of any discrepancies:
- Order Booking Form, TGA booking form & Receipts
- Finance, Insurance, Extended Warranty and Service Value Pack related documents 
- Registration related documents
2) Confirm status of vehicle readiness - Vehicle condition, VDQI completion, TGA installation, Fast-tag, TGloss
3) Call the guest on N-1 day (N is planned delivery date) and confirm time / location of delivery ceremony (dealership or home) and Special ceremony requirement
4) Informs Delivery In-charge about the delivery requirement (Home delivery, special ceremony etc.)
5) Prepare the delivery kit',
    '1) Check for the availability of delivery schedule

2) Check for the readiness of following documents
> RTO documents
> Loan documents
> Invoice 
> Insurance copy
> Order form

Note : 
VDS : Vehicle Detailing Services,VDQI : Vehicle Delivery Quality Inspection, TGloss : Toyota Gloss Studio',
    '1) Sales SOP (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ018',
    'v1-DQ018-004',
    'Operation [Sales]',
    'Showroom',
    '[Vehicle Delivery Preparation]
Does GEM-Sales check the readiness of vehicle, related documents and inform the guest about the delivery?',
    'Operation [Sales]',
    'Showroom',
    'GEM-Sales prepare the delivery kit',
    '[Vehicle Delivery Preparation]
Does GEM-Sales check the readiness of vehicle, related documents and inform the guest about the delivery?',
    'Direct',
    '3S',
    'GEM-Sales prepare the delivery kit',
    '*Ensuring the thorough readiness of vehicle, documents before delivery to avoid any inconvenience to guest.',
    '1) Check all the documents in the Customer File & get it updated in case of any discrepancies:
- Order Booking Form, TGA booking form & Receipts
- Finance, Insurance, Extended Warranty and Service Value Pack related documents 
- Registration related documents
2) Confirm status of vehicle readiness - Vehicle condition, VDQI completion, TGA installation, Fast-tag, TGloss
3) Call the guest on N-1 day (N is planned delivery date) and confirm time / location of delivery ceremony (dealership or home) and Special ceremony requirement
4) Informs Delivery In-charge about the delivery requirement (Home delivery, special ceremony etc.)
5) Prepare the delivery kit',
    '1) Check for the availability of delivery schedule

2) Check for the readiness of following documents
> RTO documents
> Loan documents
> Invoice 
> Insurance copy
> Order form

Note : 
VDS : Vehicle Detailing Services,VDQI : Vehicle Delivery Quality Inspection, TGloss : Toyota Gloss Studio',
    '1) Sales SOP (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ019',
    'v1-DQ019-001',
    'Operation [Sales]',
    'New car delivery area',
    '[New car Delivery]
Does GEM Sales explains all the vehicle details during delivery and the Vehicle is delivered as per guest expectation & dealer promise?',
    'Operation [Sales]',
    'New car delivery area',
    'GEM-Sales ensures the vehicle and related documents ready before guest arrival time along with delivery in-charge.',
    '[New car Delivery]
Does GEM Sales explains all the vehicle details during delivery and the Vehicle is delivered as per guest expectation & dealer promise?',
    'Direct',
    '3S',
    'GEM-Sales ensures the vehicle and related documents ready before guest arrival time along with delivery in-charge.',
    '*For Smooth and comfortable sales during the delivery of vehicle.',
    '1) GEM-Sales, along with delivery in-charge, keeps the vehicle and related documents ready before guest arrival time
2) GEM-Sales greets the guest & family on arrival and offer seat & beverage of choice
3) Explain the delivery kit & VDQI document
4) Introduces & installs the i-connect application in guest mobile and explain the features
5) Explains the Service details to the guest and informs the 1k Service schedule
6) Explain about Post sales follow-up & home-demo and gets guest''s convenient date for the same.
7) Introduce Sales Manager, senior management, HCR & Service team to the guest
8) Escorts the guest and family to new car delivery area and delivery ceremony is performed (key handover by senior management, delivery photo capturing)
9) Explain the vehicle feature, operating controls and safety features
10) Send the digital copies the vehicle documents (Registration docs, Insurance, Invoices, finance docs)',
    '1) Check for the availability of following documents
> RTO documents
> Loan documents
> Invoice 
> Insurance copy
> Order form',
    '1) Sales SOP (Lakshya Portal)
2) HTGE Elements (Refer Seamless SOP)
3) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ019',
    'v1-DQ019-002',
    'Operation [Sales]',
    'New car delivery area',
    '[New car Delivery]
Does GEM Sales explains all the vehicle details during delivery and the Vehicle is delivered as per guest expectation & dealer promise?',
    'Operation [Sales]',
    'New car delivery area',
    'GEM-Sales receives the guest with greeting and ensures the hospitality to guest & family as per the comfort and convinience of guest (Seating, beverages of choice etc..',
    '[New car Delivery]
Does GEM Sales explains all the vehicle details during delivery and the Vehicle is delivered as per guest expectation & dealer promise?',
    'Direct',
    '3S',
    'GEM-Sales receives the guest with greeting and ensures the hospitality to guest & family as per the comfort and convinience of guest (Seating, beverages of choice etc..',
    '*For Smooth and comfortable sales during the delivery of vehicle.',
    '1) GEM-Sales, along with delivery in-charge, keeps the vehicle and related documents ready before guest arrival time
2) GEM-Sales greets the guest & family on arrival and offer seat & beverage of choice
3) Explain the delivery kit & VDQI document
4) Introduces & installs the i-connect application in guest mobile and explain the features
5) Explains the Service details to the guest and informs the 1k Service schedule
6) Explain about Post sales follow-up & home-demo and gets guest''s convenient date for the same.
7) Introduce Sales Manager, senior management, HCR & Service team to the guest
8) Escorts the guest and family to new car delivery area and delivery ceremony is performed (key handover by senior management, delivery photo capturing)
9) Explain the vehicle feature, operating controls and safety features
10) Send the digital copies the vehicle documents (Registration docs, Insurance, Invoices, finance docs)',
    '1) Check for the availability of following documents
> RTO documents
> Loan documents
> Invoice 
> Insurance copy
> Order form',
    '1) Sales SOP (Lakshya Portal)
2) HTGE Elements (Refer Seamless SOP)
3) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ019',
    'v1-DQ019-003',
    'Operation [Sales]',
    'New car delivery area',
    '[New car Delivery]
Does GEM Sales explains all the vehicle details during delivery and the Vehicle is delivered as per guest expectation & dealer promise?',
    'Operation [Sales]',
    'New car delivery area',
    'GEM-Sales explain delivery kit, VDQI, i-Connect application installation & feature explanation',
    '[New car Delivery]
Does GEM Sales explains all the vehicle details during delivery and the Vehicle is delivered as per guest expectation & dealer promise?',
    'Direct',
    '3S',
    'GEM-Sales explain delivery kit, VDQI, i-Connect application installation & feature explanation',
    '*For Smooth and comfortable sales during the delivery of vehicle.',
    '1) GEM-Sales, along with delivery in-charge, keeps the vehicle and related documents ready before guest arrival time
2) GEM-Sales greets the guest & family on arrival and offer seat & beverage of choice
3) Explain the delivery kit & VDQI document
4) Introduces & installs the i-connect application in guest mobile and explain the features
5) Explains the Service details to the guest and informs the 1k Service schedule
6) Explain about Post sales follow-up & home-demo and gets guest''s convenient date for the same.
7) Introduce Sales Manager, senior management, HCR & Service team to the guest
8) Escorts the guest and family to new car delivery area and delivery ceremony is performed (key handover by senior management, delivery photo capturing)
9) Explain the vehicle feature, operating controls and safety features
10) Send the digital copies the vehicle documents (Registration docs, Insurance, Invoices, finance docs)',
    '1) Check for the availability of following documents
> RTO documents
> Loan documents
> Invoice 
> Insurance copy
> Order form',
    '1) Sales SOP (Lakshya Portal)
2) HTGE Elements (Refer Seamless SOP)
3) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ019',
    'v1-DQ019-004',
    'Operation [Sales]',
    'New car delivery area',
    '[New car Delivery]
Does GEM Sales explains all the vehicle details during delivery and the Vehicle is delivered as per guest expectation & dealer promise?',
    'Operation [Sales]',
    'New car delivery area',
    'GEM-Sales records and explain Post Sales follow-up (Home visit, 1K service schedule and introduces Sales manager, HCR and Service team to the guest.)',
    '[New car Delivery]
Does GEM Sales explains all the vehicle details during delivery and the Vehicle is delivered as per guest expectation & dealer promise?',
    'Direct',
    '3S',
    'GEM-Sales records and explain Post Sales follow-up (Home visit, 1K service schedule and introduces Sales manager, HCR and Service team to the guest.)',
    '*For Smooth and comfortable sales during the delivery of vehicle.',
    '1) GEM-Sales, along with delivery in-charge, keeps the vehicle and related documents ready before guest arrival time
2) GEM-Sales greets the guest & family on arrival and offer seat & beverage of choice
3) Explain the delivery kit & VDQI document
4) Introduces & installs the i-connect application in guest mobile and explain the features
5) Explains the Service details to the guest and informs the 1k Service schedule
6) Explain about Post sales follow-up & home-demo and gets guest''s convenient date for the same.
7) Introduce Sales Manager, senior management, HCR & Service team to the guest
8) Escorts the guest and family to new car delivery area and delivery ceremony is performed (key handover by senior management, delivery photo capturing)
9) Explain the vehicle feature, operating controls and safety features
10) Send the digital copies the vehicle documents (Registration docs, Insurance, Invoices, finance docs)',
    '1) Check for the availability of following documents
> RTO documents
> Loan documents
> Invoice 
> Insurance copy
> Order form',
    '1) Sales SOP (Lakshya Portal)
2) HTGE Elements (Refer Seamless SOP)
3) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ019',
    'v1-DQ019-005',
    'Operation [Sales]',
    'New car delivery area',
    '[New car Delivery]
Does GEM Sales explains all the vehicle details during delivery and the Vehicle is delivered as per guest expectation & dealer promise?',
    'Operation [Sales]',
    'New car delivery area',
    'Explain vehicle feature, operating controls, safety features (must during delivery and share the digital copies of vehicles documetns (Registration, Insurance, Invoice, Finance & others)',
    '[New car Delivery]
Does GEM Sales explains all the vehicle details during delivery and the Vehicle is delivered as per guest expectation & dealer promise?',
    'Direct',
    '3S',
    'Explain vehicle feature, operating controls, safety features (must during delivery and share the digital copies of vehicles documetns (Registration, Insurance, Invoice, Finance & others)',
    '*For Smooth and comfortable sales during the delivery of vehicle.',
    '1) GEM-Sales, along with delivery in-charge, keeps the vehicle and related documents ready before guest arrival time
2) GEM-Sales greets the guest & family on arrival and offer seat & beverage of choice
3) Explain the delivery kit & VDQI document
4) Introduces & installs the i-connect application in guest mobile and explain the features
5) Explains the Service details to the guest and informs the 1k Service schedule
6) Explain about Post sales follow-up & home-demo and gets guest''s convenient date for the same.
7) Introduce Sales Manager, senior management, HCR & Service team to the guest
8) Escorts the guest and family to new car delivery area and delivery ceremony is performed (key handover by senior management, delivery photo capturing)
9) Explain the vehicle feature, operating controls and safety features
10) Send the digital copies the vehicle documents (Registration docs, Insurance, Invoices, finance docs)',
    '1) Check for the availability of following documents
> RTO documents
> Loan documents
> Invoice 
> Insurance copy
> Order form',
    '1) Sales SOP (Lakshya Portal)
2) HTGE Elements (Refer Seamless SOP)
3) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ020',
    'v1-DQ020-001',
    'Operation [Seamless]',
    'Showroom / Service Reception',
    '[Post Sales]
Does GEM Sales performs Home Visit & 1K service initiation with guest after vehicle delivery within the prescribed time period?',
    'Operation [Seamless]',
    'Showroom / Service Reception',
    'Home visit is arranged and done by GEM-Sales based on the guest convinience captured during the delivery process.',
    '[Post Sales]
Does GEM Sales performs Home Visit & 1K service initiation with guest after vehicle delivery within the prescribed time period?',
    'Direct',
    '3S',
    'Home visit is arranged and done by GEM-Sales based on the guest convinience captured during the delivery process.',
    '*Ensuring guest are engaged and retained post sales. Also act as a single point of contact.',
    '1) Home visit is done by GEM-Sales based on the guest convenience captured during delivery process
2) MRS (Maintenance Reminder System) call plan is generated in GEM-Sales ID (Check in GEM Sales icrop log-in) and the call is done by GEM sales
3) During 1K service visit, GEM Sales receives the guest and introduces to GEM-Service
4) During 1K visit, guest is explained about Toyota Service Uniqueness (EM - Express Maintenance, Warranty - Standard; EW; SAWA, RSA, TSE) and guest is offered the service facility visit.
5) Introduce & install the i-connect application in guest mobile and explain the features (if not done during new car delivery)',
    '1) Usage of Toyota i Connect to explain the service uniqueness
2) Ensure safety of the guest when walking through the facility / workshop (Usage of safety gears, safety path)

Note : EW : Extended Warranty, SAWA : Service Activiated Warranty, RSA : Roas Side assistance, TSE : Toyota Service Express',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ020',
    'v1-DQ020-002',
    'Operation [Seamless]',
    'Showroom / Service Reception',
    '[Post Sales]
Does GEM Sales performs Home Visit & 1K service initiation with guest after vehicle delivery within the prescribed time period?',
    'Operation [Seamless]',
    'Showroom / Service Reception',
    'GEM-Sales performs MRS Call for 1K service as per the call plan and ensures appointment taken by guest is planned in the SMB.',
    '[Post Sales]
Does GEM Sales performs Home Visit & 1K service initiation with guest after vehicle delivery within the prescribed time period?',
    'Direct',
    '3S',
    'GEM-Sales performs MRS Call for 1K service as per the call plan and ensures appointment taken by guest is planned in the SMB.',
    '*Ensuring guest are engaged and retained post sales. Also act as a single point of contact.',
    '1) Home visit is done by GEM-Sales based on the guest convenience captured during delivery process
2) MRS (Maintenance Reminder System) call plan is generated in GEM-Sales ID (Check in GEM Sales icrop log-in) and the call is done by GEM sales
3) During 1K service visit, GEM Sales receives the guest and introduces to GEM-Service
4) During 1K visit, guest is explained about Toyota Service Uniqueness (EM - Express Maintenance, Warranty - Standard; EW; SAWA, RSA, TSE) and guest is offered the service facility visit.
5) Introduce & install the i-connect application in guest mobile and explain the features (if not done during new car delivery)',
    '1) Usage of Toyota i Connect to explain the service uniqueness
2) Ensure safety of the guest when walking through the facility / workshop (Usage of safety gears, safety path)

Note : EW : Extended Warranty, SAWA : Service Activiated Warranty, RSA : Roas Side assistance, TSE : Toyota Service Express',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ020',
    'v1-DQ020-003',
    'Operation [Seamless]',
    'Showroom / Service Reception',
    '[Post Sales]
Does GEM Sales performs Home Visit & 1K service initiation with guest after vehicle delivery within the prescribed time period?',
    'Operation [Seamless]',
    'Showroom / Service Reception',
    'During 1K service visit, GEM-Sales received the guest, intoduces GEM-Service and explain Toyota Service Uniqueness & benefits.',
    '[Post Sales]
Does GEM Sales performs Home Visit & 1K service initiation with guest after vehicle delivery within the prescribed time period?',
    'Direct',
    '3S',
    'During 1K service visit, GEM-Sales received the guest, intoduces GEM-Service and explain Toyota Service Uniqueness & benefits.',
    '*Ensuring guest are engaged and retained post sales. Also act as a single point of contact.',
    '1) Home visit is done by GEM-Sales based on the guest convenience captured during delivery process
2) MRS (Maintenance Reminder System) call plan is generated in GEM-Sales ID (Check in GEM Sales icrop log-in) and the call is done by GEM sales
3) During 1K service visit, GEM Sales receives the guest and introduces to GEM-Service
4) During 1K visit, guest is explained about Toyota Service Uniqueness (EM - Express Maintenance, Warranty - Standard; EW; SAWA, RSA, TSE) and guest is offered the service facility visit.
5) Introduce & install the i-connect application in guest mobile and explain the features (if not done during new car delivery)',
    '1) Usage of Toyota i Connect to explain the service uniqueness
2) Ensure safety of the guest when walking through the facility / workshop (Usage of safety gears, safety path)

Note : EW : Extended Warranty, SAWA : Service Activiated Warranty, RSA : Roas Side assistance, TSE : Toyota Service Express',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ021',
    'v1-DQ021-001',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'PO to explain the benefits / USPs of U Trust to customer & perform NAB process (incase of any other source of enquiry',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Indirect',
    '3S',
    'PO to explain the benefits / USPs of U Trust to customer & perform NAB process (incase of any other source of enquiry',
    '*Ensures right valuation of Used car.',
    '1) Check by observing / role play of valuation on one vehicle (utilize already valuated vehicle) and check the results updated in the valuation sheet
- Physical copy of valuation sheet with filled data
- Tool kit usage 
- Perform Valuation for 203 check point
- Enquiry wise monitoring of details & follow up
2) Procurement Officer (PO) co-ordination with GEM-Sales while contacting Replacement Enquiry customer (introduction, pricing communication, Negotiation, Closing)',
    '1) Valuation sheet
2) Tools & Tool kit equivalent to the Count of Procurement Officers (PO)
3) UCTDMS for price information update to GEM-Sales',
    '1) Used Car Valuation SOP
2) Valuation Check Sheet (TKM Standard)',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ021',
    'v1-DQ021-002',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Perform Valuation using vehicle inspection sheet (203 check points & tool kit)',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Indirect',
    '3S',
    'Perform Valuation using vehicle inspection sheet (203 check points & tool kit)',
    '*Ensures right valuation of Used car.',
    '1) Check by observing / role play of valuation on one vehicle (utilize already valuated vehicle) and check the results updated in the valuation sheet
- Physical copy of valuation sheet with filled data
- Tool kit usage 
- Perform Valuation for 203 check point
- Enquiry wise monitoring of details & follow up
2) Procurement Officer (PO) co-ordination with GEM-Sales while contacting Replacement Enquiry customer (introduction, pricing communication, Negotiation, Closing)',
    '1) Valuation sheet
2) Tools & Tool kit equivalent to the Count of Procurement Officers (PO)
3) UCTDMS for price information update to GEM-Sales',
    '1) Used Car Valuation SOP
2) Valuation Check Sheet (TKM Standard)',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ021',
    'v1-DQ021-003',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Valuations performed should be captured in valuation sheets along with proper follow up details, negotiation details, quality rating calculations & signatures on sheet',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Indirect',
    '3S',
    'Valuations performed should be captured in valuation sheets along with proper follow up details, negotiation details, quality rating calculations & signatures on sheet',
    '*Ensures right valuation of Used car.',
    '1) Check by observing / role play of valuation on one vehicle (utilize already valuated vehicle) and check the results updated in the valuation sheet
- Physical copy of valuation sheet with filled data
- Tool kit usage 
- Perform Valuation for 203 check point
- Enquiry wise monitoring of details & follow up
2) Procurement Officer (PO) co-ordination with GEM-Sales while contacting Replacement Enquiry customer (introduction, pricing communication, Negotiation, Closing)',
    '1) Valuation sheet
2) Tools & Tool kit equivalent to the Count of Procurement Officers (PO)
3) UCTDMS for price information update to GEM-Sales',
    '1) Used Car Valuation SOP
2) Valuation Check Sheet (TKM Standard)',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ021',
    'v1-DQ021-004',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'U-Trust Team to maintain enquiry list/card with details and GEM-Sales wise, Model-wise, Outlet-wise enquiry analysis (NVS replace enquiry to Valuation rate, U-trust enquiry to valuation ratio',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Indirect',
    '3S',
    'U-Trust Team to maintain enquiry list/card with details and GEM-Sales wise, Model-wise, Outlet-wise enquiry analysis (NVS replace enquiry to Valuation rate, U-trust enquiry to valuation ratio',
    '*Ensures right valuation of Used car.',
    '1) Check by observing / role play of valuation on one vehicle (utilize already valuated vehicle) and check the results updated in the valuation sheet
- Physical copy of valuation sheet with filled data
- Tool kit usage 
- Perform Valuation for 203 check point
- Enquiry wise monitoring of details & follow up
2) Procurement Officer (PO) co-ordination with GEM-Sales while contacting Replacement Enquiry customer (introduction, pricing communication, Negotiation, Closing)',
    '1) Valuation sheet
2) Tools & Tool kit equivalent to the Count of Procurement Officers (PO)
3) UCTDMS for price information update to GEM-Sales',
    '1) Used Car Valuation SOP
2) Valuation Check Sheet (TKM Standard)',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ021',
    'v1-DQ021-005',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Performs follow up and enter all the follow up details in system',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Indirect',
    '3S',
    'Performs follow up and enter all the follow up details in system',
    '*Ensures right valuation of Used car.',
    '1) Check by observing / role play of valuation on one vehicle (utilize already valuated vehicle) and check the results updated in the valuation sheet
- Physical copy of valuation sheet with filled data
- Tool kit usage 
- Perform Valuation for 203 check point
- Enquiry wise monitoring of details & follow up
2) Procurement Officer (PO) co-ordination with GEM-Sales while contacting Replacement Enquiry customer (introduction, pricing communication, Negotiation, Closing)',
    '1) Valuation sheet
2) Tools & Tool kit equivalent to the Count of Procurement Officers (PO)
3) UCTDMS for price information update to GEM-Sales',
    '1) Used Car Valuation SOP
2) Valuation Check Sheet (TKM Standard)',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ021',
    'v1-DQ021-006',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Used Car Purchase Pricing communication with confirmation from PTL',
    'Does dealer performs Used car valuation as per the TKM guideline?',
    'Indirect',
    '3S',
    'Used Car Purchase Pricing communication with confirmation from PTL',
    '*Ensures right valuation of Used car.',
    '1) Check by observing / role play of valuation on one vehicle (utilize already valuated vehicle) and check the results updated in the valuation sheet
- Physical copy of valuation sheet with filled data
- Tool kit usage 
- Perform Valuation for 203 check point
- Enquiry wise monitoring of details & follow up
2) Procurement Officer (PO) co-ordination with GEM-Sales while contacting Replacement Enquiry customer (introduction, pricing communication, Negotiation, Closing)',
    '1) Valuation sheet
2) Tools & Tool kit equivalent to the Count of Procurement Officers (PO)
3) UCTDMS for price information update to GEM-Sales',
    '1) Used Car Valuation SOP
2) Valuation Check Sheet (TKM Standard)',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ022',
    'v1-DQ022-001',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Used Car Sales Officer (SO explains USPs of U Trust to customer)',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Direct',
    '3S',
    'Used Car Sales Officer (SO explains USPs of U Trust to customer)',
    '*Ensures the used care sales to guest with all the benefit and USPs

*Ensuring the capture of all potential leads for Used Car retails',
    '1) Check by observing / Role play with Used Car SO''s (Sales Officer)
2) Check Buyer enquiry card & system entering check
3) Check tracking and monitoring sheet of all leads',
    '1) UCTDMS
2) Buyer Enquiry Card

Note : USP : Unique Selling Points',
    '1) Used Car Sales SOP',
    false,
    '["Used Car"]'::jsonb,
    'active'
  );

INSERT INTO audit_checklist_master (
  checklist_code,
  version,
  section,
  area,
  chapter,
  classification,
  location_aspect,
  evaluation_question,
  evaluation_parameter,
  guest_experience_impact,
  facility_type,
  question,
  purpose,
  checking_method,
  additional_info,
  sop_reference,
  evidence_required,
  applicable_departments,
  status
) VALUES
(
    'DQ022',
    'v1-DQ022-002',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Understands the customer requirement & propose relevant vehicle',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Direct',
    '3S',
    'Understands the customer requirement & propose relevant vehicle',
    '*Ensures the used care sales to guest with all the benefit and USPs

*Ensuring the capture of all potential leads for Used Car retails',
    '1) Check by observing / Role play with Used Car SO''s (Sales Officer)
2) Check Buyer enquiry card & system entering check
3) Check tracking and monitoring sheet of all leads',
    '1) UCTDMS
2) Buyer Enquiry Card

Note : USP : Unique Selling Points',
    '1) Used Car Sales SOP',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ022',
    'v1-DQ022-003',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Explains the vehicle & its condition along with vehicle USPs (both Toyota & Non-Toyota',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Direct',
    '3S',
    'Explains the vehicle & its condition along with vehicle USPs (both Toyota & Non-Toyota',
    '*Ensures the used care sales to guest with all the benefit and USPs

*Ensuring the capture of all potential leads for Used Car retails',
    '1) Check by observing / Role play with Used Car SO''s (Sales Officer)
2) Check Buyer enquiry card & system entering check
3) Check tracking and monitoring sheet of all leads',
    '1) UCTDMS
2) Buyer Enquiry Card

Note : USP : Unique Selling Points',
    '1) Used Car Sales SOP',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ022',
    'v1-DQ022-004',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Explains certified vehicle benefits to customer (certification, warranty, Free service, RSA',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Direct',
    '3S',
    'Explains certified vehicle benefits to customer (certification, warranty, Free service, RSA',
    '*Ensures the used care sales to guest with all the benefit and USPs

*Ensuring the capture of all potential leads for Used Car retails',
    '1) Check by observing / Role play with Used Car SO''s (Sales Officer)
2) Check Buyer enquiry card & system entering check
3) Check tracking and monitoring sheet of all leads',
    '1) UCTDMS
2) Buyer Enquiry Card

Note : USP : Unique Selling Points',
    '1) Used Car Sales SOP',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ022',
    'v1-DQ022-005',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Used Car SO pitching VAS (Finance, EW, Gloss Studio, Accessories, Smiles Package',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Direct',
    '3S',
    'Used Car SO pitching VAS (Finance, EW, Gloss Studio, Accessories, Smiles Package',
    '*Ensures the used care sales to guest with all the benefit and USPs

*Ensuring the capture of all potential leads for Used Car retails',
    '1) Check by observing / Role play with Used Car SO''s (Sales Officer)
2) Check Buyer enquiry card & system entering check
3) Check tracking and monitoring sheet of all leads',
    '1) UCTDMS
2) Buyer Enquiry Card

Note : USP : Unique Selling Points',
    '1) Used Car Sales SOP',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ022',
    'v1-DQ022-006',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Filling of Buyer Enquiry Card & follow up details entering in sheet & systems',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Direct',
    '3S',
    'Filling of Buyer Enquiry Card & follow up details entering in sheet & systems',
    '*Ensures the used care sales to guest with all the benefit and USPs

*Ensuring the capture of all potential leads for Used Car retails',
    '1) Check by observing / Role play with Used Car SO''s (Sales Officer)
2) Check Buyer enquiry card & system entering check
3) Check tracking and monitoring sheet of all leads',
    '1) UCTDMS
2) Buyer Enquiry Card

Note : USP : Unique Selling Points',
    '1) Used Car Sales SOP',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ022',
    'v1-DQ022-007',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Tracking and monitoring of all source leads (Sales, Service, digital, physical',
    'Does dealer performs Used car retail / sales as per the TKM guideline?',
    'Direct',
    '3S',
    'Tracking and monitoring of all source leads (Sales, Service, digital, physical',
    '*Ensures the used care sales to guest with all the benefit and USPs

*Ensuring the capture of all potential leads for Used Car retails',
    '1) Check by observing / Role play with Used Car SO''s (Sales Officer)
2) Check Buyer enquiry card & system entering check
3) Check tracking and monitoring sheet of all leads',
    '1) UCTDMS
2) Buyer Enquiry Card

Note : USP : Unique Selling Points',
    '1) Used Car Sales SOP',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ023',
    'v1-DQ023-001',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer ensure appropriate Documentation during the Used car sales process?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Valuation sheet',
    'Does dealer ensure appropriate Documentation during the Used car sales process?',
    'Indirect',
    '3S',
    'Valuation sheet',
    '*Ensuring no documentation missing during the purchase and sales of used car',
    '1) Check Physical copy of valuation sheet with data
2) Check Physical check of documents from vehicle file
3) Matching of price & vehicle details with UCTDMS
4) Finance documents for amount transaction',
    '1) Valuation sheet
2) Vehicle documents
3) Customer KYC Documents
4) Transactional Documents',
    '1) Used Car SOP & Documentation checklist',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ023',
    'v1-DQ023-002',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer ensure appropriate Documentation during the Used car sales process?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Purchase Documents : Purchased vehicles documents are maintained along with relevant information : As per Purchase checklist (available in UCTDMS',
    'Does dealer ensure appropriate Documentation during the Used car sales process?',
    'Indirect',
    '3S',
    'Purchase Documents : Purchased vehicles documents are maintained along with relevant information : As per Purchase checklist (available in UCTDMS',
    '*Ensuring no documentation missing during the purchase and sales of used car',
    '1) Check Physical copy of valuation sheet with data
2) Check Physical check of documents from vehicle file
3) Matching of price & vehicle details with UCTDMS
4) Finance documents for amount transaction',
    '1) Valuation sheet
2) Vehicle documents
3) Customer KYC Documents
4) Transactional Documents',
    '1) Used Car SOP & Documentation checklist',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ023',
    'v1-DQ023-003',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Does dealer ensure appropriate Documentation during the Used car sales process?',
    'Operation [Used Car]',
    'U-Trust Reception / Office',
    'Retail documents :Retail vehicles documents are maintained along with relevant information : As per Retail Checklist (available in UCTDMS',
    'Does dealer ensure appropriate Documentation during the Used car sales process?',
    'Indirect',
    '3S',
    'Retail documents :Retail vehicles documents are maintained along with relevant information : As per Retail Checklist (available in UCTDMS',
    '*Ensuring no documentation missing during the purchase and sales of used car',
    '1) Check Physical copy of valuation sheet with data
2) Check Physical check of documents from vehicle file
3) Matching of price & vehicle details with UCTDMS
4) Finance documents for amount transaction',
    '1) Valuation sheet
2) Vehicle documents
3) Customer KYC Documents
4) Transactional Documents',
    '1) Used Car SOP & Documentation checklist',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ024',
    'v1-DQ024-001',
    'Operation [Used Car]',
    'U-Trust Display',
    'Does dealer performs used car certification as per TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Display',
    'Certified vehicle / Certification applied vehicle should have done / completed Refurbishment (RF , Preiodic Maintenance Service (PMS))',
    'Does dealer performs used car certification as per TKM guideline?',
    'Direct',
    '3S',
    'Certified vehicle / Certification applied vehicle should have done / completed Refurbishment (RF , Preiodic Maintenance Service (PMS))',
    '*Ensuring the right and appropriate purchase of Used car',
    '1) Check Vehicle accidental history availability of certified vehicles
2) Check Vehicle Service History availability of certified vehicles
3) Check Vehicle RF (Refurbishment) level check of certified vehicles',
    '1) Used Car Certified Vehicle  
2) TopServ',
    '1) Used car Certification Process',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ024',
    'v1-DQ024-002',
    'Operation [Used Car]',
    'U-Trust Display',
    'Does dealer performs used car certification as per TKM guideline?',
    'Operation [Used Car]',
    'U-Trust Display',
    'Should meet all certification criteria (non accidental, Proper Periodic service history, Non flooded, Non odometer tampered etc.',
    'Does dealer performs used car certification as per TKM guideline?',
    'Direct',
    '3S',
    'Should meet all certification criteria (non accidental, Proper Periodic service history, Non flooded, Non odometer tampered etc.',
    '*Ensuring the right and appropriate purchase of Used car',
    '1) Check Vehicle accidental history availability of certified vehicles
2) Check Vehicle Service History availability of certified vehicles
3) Check Vehicle RF (Refurbishment) level check of certified vehicles',
    '1) Used Car Certified Vehicle  
2) TopServ',
    '1) Used car Certification Process',
    false,
    '["Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ025',
    'v1-DQ025-001',
    'Facility',
    'Showroom & Service Reception',
    'Does the Dealer have a Guest lounge that is comfortable and meets Distributor guidelines?',
    'Facility',
    'Showroom & Service Reception',
    'Guest lounge has comfortable seating for Guest and has the engagement options (e.g. TV, news paper, magazines, internet etc.',
    'Does the Dealer have a Guest lounge that is comfortable and meets Distributor guidelines?',
    'Direct',
    '3S',
    'Guest lounge has comfortable seating for Guest and has the engagement options (e.g. TV, news paper, magazines, internet etc.',
    '*It is important that the Guest can be accommodated in an area that is warm, friendly, quiet and clean. A relaxed Guest is a happy Guest. 

*Providing suitable accommodation for the families of Guests will increase the probability of selling more products.',
    'Check the below mentioned facilities in Guest lounge 
1)  Check if the lounge is as per the DIVA standard (Distributor guidelines).
2) Check that Guest lounge includes suitable seats, beverages, air-conditioning and means of entertainment. (ex: TV, newspapers, etc.)
3) Check for the digital display of service (Q-Service promotional videos/poster, PM Price menu, EM menu) & new car information (Qcast)
4) Check if EM bays are visible from lounge or the EM work is live streamed in the lounge (in case bays are not visible)
5) Check the condition of the toilet (Hygiene, odour, condition & functionality of equipment - faucet, toilet seat, flush) and availability of toilet accessories like soap, toilet paper, hand dryer, air freshener etc.',
    '1) Suitable seats (as per DIVA guide), beverages, air-conditioning and entertainment options (ex: TV, newspapers), 
2) Operational CS Board should be available in Owner''s lounge [recommended in driver''s lounge also]
3) The information about service and the new car should be displayed using Qcast
4) Availability of a regularly updated self-check sheet for toilet maintenance and cleaning (Look for cross verification / validation / supervision of maintenance)',
    '1) DIVA guidelines (Guest waiting lounge & driver waiting lounge)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ025',
    'v1-DQ025-002',
    'Facility',
    'Showroom & Service Reception',
    'Does the Dealer have a Guest lounge that is comfortable and meets Distributor guidelines?',
    'Facility',
    'Showroom & Service Reception',
    'Cafeteria is available in / near lounge to serve guest preferred beverages (display available with beverage option and the staff available in the lounge to attend the Guest)',
    'Does the Dealer have a Guest lounge that is comfortable and meets Distributor guidelines?',
    'Direct',
    '3S',
    'Cafeteria is available in / near lounge to serve guest preferred beverages (display available with beverage option and the staff available in the lounge to attend the Guest)',
    '*It is important that the Guest can be accommodated in an area that is warm, friendly, quiet and clean. A relaxed Guest is a happy Guest. 

*Providing suitable accommodation for the families of Guests will increase the probability of selling more products.',
    'Check the below mentioned facilities in Guest lounge 
1)  Check if the lounge is as per the DIVA standard (Distributor guidelines).
2) Check that Guest lounge includes suitable seats, beverages, air-conditioning and means of entertainment. (ex: TV, newspapers, etc.)
3) Check for the digital display of service (Q-Service promotional videos/poster, PM Price menu, EM menu) & new car information (Qcast)
4) Check if EM bays are visible from lounge or the EM work is live streamed in the lounge (in case bays are not visible)
5) Check the condition of the toilet (Hygiene, odour, condition & functionality of equipment - faucet, toilet seat, flush) and availability of toilet accessories like soap, toilet paper, hand dryer, air freshener etc.',
    '1) Suitable seats (as per DIVA guide), beverages, air-conditioning and entertainment options (ex: TV, newspapers), 
2) Operational CS Board should be available in Owner''s lounge [recommended in driver''s lounge also]
3) The information about service and the new car should be displayed using Qcast
4) Availability of a regularly updated self-check sheet for toilet maintenance and cleaning (Look for cross verification / validation / supervision of maintenance)',
    '1) DIVA guidelines (Guest waiting lounge & driver waiting lounge)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ025',
    'v1-DQ025-003',
    'Facility',
    'Showroom & Service Reception',
    'Does the Dealer have a Guest lounge that is comfortable and meets Distributor guidelines?',
    'Facility',
    'Showroom & Service Reception',
    'EM bays and work is visible from guest lounge. In case the EM bays are not visible, live streaming of EM operation on a TV in the guest lounge is arranged.',
    'Does the Dealer have a Guest lounge that is comfortable and meets Distributor guidelines?',
    'Direct',
    '3S',
    'EM bays and work is visible from guest lounge. In case the EM bays are not visible, live streaming of EM operation on a TV in the guest lounge is arranged.',
    '*It is important that the Guest can be accommodated in an area that is warm, friendly, quiet and clean. A relaxed Guest is a happy Guest. 

*Providing suitable accommodation for the families of Guests will increase the probability of selling more products.',
    'Check the below mentioned facilities in Guest lounge 
1)  Check if the lounge is as per the DIVA standard (Distributor guidelines).
2) Check that Guest lounge includes suitable seats, beverages, air-conditioning and means of entertainment. (ex: TV, newspapers, etc.)
3) Check for the digital display of service (Q-Service promotional videos/poster, PM Price menu, EM menu) & new car information (Qcast)
4) Check if EM bays are visible from lounge or the EM work is live streamed in the lounge (in case bays are not visible)
5) Check the condition of the toilet (Hygiene, odour, condition & functionality of equipment - faucet, toilet seat, flush) and availability of toilet accessories like soap, toilet paper, hand dryer, air freshener etc.',
    '1) Suitable seats (as per DIVA guide), beverages, air-conditioning and entertainment options (ex: TV, newspapers), 
2) Operational CS Board should be available in Owner''s lounge [recommended in driver''s lounge also]
3) The information about service and the new car should be displayed using Qcast
4) Availability of a regularly updated self-check sheet for toilet maintenance and cleaning (Look for cross verification / validation / supervision of maintenance)',
    '1) DIVA guidelines (Guest waiting lounge & driver waiting lounge)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ025',
    'v1-DQ025-004',
    'Facility',
    'Showroom & Service Reception',
    'Does the Dealer have a Guest lounge that is comfortable and meets Distributor guidelines?',
    'Facility',
    'Showroom & Service Reception',
    'Promotional videos are played in the Lounge using Q-Cast (Service / Sales Promotion, Value chain products',
    'Does the Dealer have a Guest lounge that is comfortable and meets Distributor guidelines?',
    'Direct',
    '3S',
    'Promotional videos are played in the Lounge using Q-Cast (Service / Sales Promotion, Value chain products',
    '*It is important that the Guest can be accommodated in an area that is warm, friendly, quiet and clean. A relaxed Guest is a happy Guest. 

*Providing suitable accommodation for the families of Guests will increase the probability of selling more products.',
    'Check the below mentioned facilities in Guest lounge 
1)  Check if the lounge is as per the DIVA standard (Distributor guidelines).
2) Check that Guest lounge includes suitable seats, beverages, air-conditioning and means of entertainment. (ex: TV, newspapers, etc.)
3) Check for the digital display of service (Q-Service promotional videos/poster, PM Price menu, EM menu) & new car information (Qcast)
4) Check if EM bays are visible from lounge or the EM work is live streamed in the lounge (in case bays are not visible)
5) Check the condition of the toilet (Hygiene, odour, condition & functionality of equipment - faucet, toilet seat, flush) and availability of toilet accessories like soap, toilet paper, hand dryer, air freshener etc.',
    '1) Suitable seats (as per DIVA guide), beverages, air-conditioning and entertainment options (ex: TV, newspapers), 
2) Operational CS Board should be available in Owner''s lounge [recommended in driver''s lounge also]
3) The information about service and the new car should be displayed using Qcast
4) Availability of a regularly updated self-check sheet for toilet maintenance and cleaning (Look for cross verification / validation / supervision of maintenance)',
    '1) DIVA guidelines (Guest waiting lounge & driver waiting lounge)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ025',
    'v1-DQ025-005',
    'Facility',
    'Showroom & Service Reception',
    'Does the Dealer have a Guest lounge that is comfortable and meets Distributor guidelines?',
    'Facility',
    'Showroom & Service Reception',
    'Guest Toilets are well maintained (facilities, amenities, equipment and hygiene',
    'Does the Dealer have a Guest lounge that is comfortable and meets Distributor guidelines?',
    'Direct',
    '3S',
    'Guest Toilets are well maintained (facilities, amenities, equipment and hygiene',
    '*It is important that the Guest can be accommodated in an area that is warm, friendly, quiet and clean. A relaxed Guest is a happy Guest. 

*Providing suitable accommodation for the families of Guests will increase the probability of selling more products.',
    'Check the below mentioned facilities in Guest lounge 
1)  Check if the lounge is as per the DIVA standard (Distributor guidelines).
2) Check that Guest lounge includes suitable seats, beverages, air-conditioning and means of entertainment. (ex: TV, newspapers, etc.)
3) Check for the digital display of service (Q-Service promotional videos/poster, PM Price menu, EM menu) & new car information (Qcast)
4) Check if EM bays are visible from lounge or the EM work is live streamed in the lounge (in case bays are not visible)
5) Check the condition of the toilet (Hygiene, odour, condition & functionality of equipment - faucet, toilet seat, flush) and availability of toilet accessories like soap, toilet paper, hand dryer, air freshener etc.',
    '1) Suitable seats (as per DIVA guide), beverages, air-conditioning and entertainment options (ex: TV, newspapers), 
2) Operational CS Board should be available in Owner''s lounge [recommended in driver''s lounge also]
3) The information about service and the new car should be displayed using Qcast
4) Availability of a regularly updated self-check sheet for toilet maintenance and cleaning (Look for cross verification / validation / supervision of maintenance)',
    '1) DIVA guidelines (Guest waiting lounge & driver waiting lounge)',
    false,
    '["Sales","Service & Parts","Used Car","Accessory","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ026',
    'v1-DQ026-001',
    'Facility',
    'Service Reception',
    'Does the dealer has service reception facilities as per distributor guidelines or DIVA standards?',
    'Facility',
    'Service Reception',
    'Service reception bays are as per DIVA standard and 4S is maintained',
    'Does the dealer has service reception facilities as per distributor guidelines or DIVA standards?',
    'Direct',
    '3S',
    'Service reception bays are as per DIVA standard and 4S is maintained',
    '*Proper and comfortable handling and receiving of guest and his vehicle.

*Ensure the one-stop solution and promote the products as per the need of guests.',
    '1) Check the Bay size [5*8 mts] for service reception.
2) Check the service reception bay is done with Green color epoxy
3) Check Gloss studio branding [Capsule availability to be checked inline with SBU guideline]
4) Car essentials display with TKM recommended materials in display',
    '1) Tire & Battery schemes & offering information to Service team
2) Tools used to promote to all customers
3) Tire & Battery Displayed in stand for Guest Awareness
4) Observation in car essential store',
    '1) DIVA guidelines (Service Reception area)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ026',
    'v1-DQ026-002',
    'Facility',
    'Service Reception',
    'Does the dealer has service reception facilities as per distributor guidelines or DIVA standards?',
    'Facility',
    'Service Reception',
    'Availability of tools /equipment used in reception (GTS for diagnosis - minimum one in reception area, Battery tester - Medtronic tool, Tire depth gauge, BP Estimation kit etc...',
    'Does the dealer has service reception facilities as per distributor guidelines or DIVA standards?',
    'Direct',
    '3S',
    'Availability of tools /equipment used in reception (GTS for diagnosis - minimum one in reception area, Battery tester - Medtronic tool, Tire depth gauge, BP Estimation kit etc...',
    '*Proper and comfortable handling and receiving of guest and his vehicle.

*Ensure the one-stop solution and promote the products as per the need of guests.',
    '1) Check the Bay size [5*8 mts] for service reception.
2) Check the service reception bay is done with Green color epoxy
3) Check Gloss studio branding [Capsule availability to be checked inline with SBU guideline]
4) Car essentials display with TKM recommended materials in display',
    '1) Tire & Battery schemes & offering information to Service team
2) Tools used to promote to all customers
3) Tire & Battery Displayed in stand for Guest Awareness
4) Observation in car essential store',
    '1) DIVA guidelines (Service Reception area)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ026',
    'v1-DQ026-003',
    'Facility',
    'Service Reception',
    'Does the dealer has service reception facilities as per distributor guidelines or DIVA standards?',
    'Facility',
    'Service Reception',
    'TKM recommended promotion items are in display in service reception area (Digital / physical as per TKM recommendation',
    'Does the dealer has service reception facilities as per distributor guidelines or DIVA standards?',
    'Direct',
    '3S',
    'TKM recommended promotion items are in display in service reception area (Digital / physical as per TKM recommendation',
    '*Proper and comfortable handling and receiving of guest and his vehicle.

*Ensure the one-stop solution and promote the products as per the need of guests.',
    '1) Check the Bay size [5*8 mts] for service reception.
2) Check the service reception bay is done with Green color epoxy
3) Check Gloss studio branding [Capsule availability to be checked inline with SBU guideline]
4) Car essentials display with TKM recommended materials in display',
    '1) Tire & Battery schemes & offering information to Service team
2) Tools used to promote to all customers
3) Tire & Battery Displayed in stand for Guest Awareness
4) Observation in car essential store',
    '1) DIVA guidelines (Service Reception area)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ027',
    'v1-DQ027-001',
    'Operation [Service]',
    'Service Reception',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Operation [Service]',
    'Service Reception',
    'Guests are received immediately on arrival (appointment on-time arrived to be received with 5 mins and other guest with in 10 mins. EM appointments to be prioritized',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Direct',
    '3S',
    'Guests are received immediately on arrival (appointment on-time arrived to be received with 5 mins and other guest with in 10 mins. EM appointments to be prioritized',
    '* Enable staff to make appropriate diagnosis &  propose for repair / maintenance.

* Prevent accidents result from improper usage of floor mats

* To ensure that accurate job instructions are provided by accurately confirming Guests’ requests and ensuring there are no oversights 

* To take care of Guest vehicle and the valuables',
    '1) Observe reception Process of at least 1 GS & 1 BP vehicle and confirm the following
- Guests are greeted on arrival by service staff and offered seat and preferred beverage
- Check if Guests are received by GEM Service immediately on arrival (not more 5 mins for appointment & on-time arrival guest & 10 mins for other guests. Arriving with in  +/- 15 mins from planned appointment time is considered as on-time arrival)
- Is the CGT time available at reception for General Repair requiring diagnosis.
- Check whether Floor Mat installation condition (lock, Non-Genuine, Multiple floor mats etc.) is  recorded in AWACS and informed to Guest.
- Check if tire & battery condition is checked using the recommended tools, TGloss requirement is assessed based on the vehicle condition and right value chain products are offered to guest.
- iConnect App is used when necessary to explain the service features and value chain products
2) Check the following documents and confirm if the guest requests, Service/repair/damage details are recorded and guest approval is taken
- 3 sample in GS: AWACS[Non-eCRB], Repair Order (RO), Diagnostic Questionnaire (DQ)
- 3 samples of B&P AWACS to confirm if Guest requests and damage details are recorded
- 3 samples of BP Estimate to confirm individual jobs (repair panel) and damage area is clearly marked on vehicle image',
    '1) AWAC (Appointment & Walk Around Checksheet) / e-CRB Tab
2) Repair order copy
3) Diagnosis Questionnaire
4) Floormat Installation condition
5) BP AWAC Sheet from Document Control Board
6) BP Estimate Copy
7) iConnect App',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ027',
    'v1-DQ027-002',
    'Operation [Service]',
    'Service Reception',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Operation [Service]',
    'Service Reception',
    'Same GEM-Service who attended the guest during previous visit is assigned (exception: guest requesting for any other GEM, GEM is on leave or busy with other guest',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Direct',
    '3S',
    'Same GEM-Service who attended the guest during previous visit is assigned (exception: guest requesting for any other GEM, GEM is on leave or busy with other guest',
    '* Enable staff to make appropriate diagnosis &  propose for repair / maintenance.

* Prevent accidents result from improper usage of floor mats

* To ensure that accurate job instructions are provided by accurately confirming Guests’ requests and ensuring there are no oversights 

* To take care of Guest vehicle and the valuables',
    '1) Observe reception Process of at least 1 GS & 1 BP vehicle and confirm the following
- Guests are greeted on arrival by service staff and offered seat and preferred beverage
- Check if Guests are received by GEM Service immediately on arrival (not more 5 mins for appointment & on-time arrival guest & 10 mins for other guests. Arriving with in  +/- 15 mins from planned appointment time is considered as on-time arrival)
- Is the CGT time available at reception for General Repair requiring diagnosis.
- Check whether Floor Mat installation condition (lock, Non-Genuine, Multiple floor mats etc.) is  recorded in AWACS and informed to Guest.
- Check if tire & battery condition is checked using the recommended tools, TGloss requirement is assessed based on the vehicle condition and right value chain products are offered to guest.
- iConnect App is used when necessary to explain the service features and value chain products
2) Check the following documents and confirm if the guest requests, Service/repair/damage details are recorded and guest approval is taken
- 3 sample in GS: AWACS[Non-eCRB], Repair Order (RO), Diagnostic Questionnaire (DQ)
- 3 samples of B&P AWACS to confirm if Guest requests and damage details are recorded
- 3 samples of BP Estimate to confirm individual jobs (repair panel) and damage area is clearly marked on vehicle image',
    '1) AWAC (Appointment & Walk Around Checksheet) / e-CRB Tab
2) Repair order copy
3) Diagnosis Questionnaire
4) Floormat Installation condition
5) BP AWAC Sheet from Document Control Board
6) BP Estimate Copy
7) iConnect App',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ027',
    'v1-DQ027-003',
    'Operation [Service]',
    'Service Reception',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Operation [Service]',
    'Service Reception',
    'GEM-Service perform walk-around check & accurately capture/confirm Guest''s requests in TOPSERV / eCRB',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Direct',
    '3S',
    'GEM-Service perform walk-around check & accurately capture/confirm Guest''s requests in TOPSERV / eCRB',
    '* Enable staff to make appropriate diagnosis &  propose for repair / maintenance.

* Prevent accidents result from improper usage of floor mats

* To ensure that accurate job instructions are provided by accurately confirming Guests’ requests and ensuring there are no oversights 

* To take care of Guest vehicle and the valuables',
    '1) Observe reception Process of at least 1 GS & 1 BP vehicle and confirm the following
- Guests are greeted on arrival by service staff and offered seat and preferred beverage
- Check if Guests are received by GEM Service immediately on arrival (not more 5 mins for appointment & on-time arrival guest & 10 mins for other guests. Arriving with in  +/- 15 mins from planned appointment time is considered as on-time arrival)
- Is the CGT time available at reception for General Repair requiring diagnosis.
- Check whether Floor Mat installation condition (lock, Non-Genuine, Multiple floor mats etc.) is  recorded in AWACS and informed to Guest.
- Check if tire & battery condition is checked using the recommended tools, TGloss requirement is assessed based on the vehicle condition and right value chain products are offered to guest.
- iConnect App is used when necessary to explain the service features and value chain products
2) Check the following documents and confirm if the guest requests, Service/repair/damage details are recorded and guest approval is taken
- 3 sample in GS: AWACS[Non-eCRB], Repair Order (RO), Diagnostic Questionnaire (DQ)
- 3 samples of B&P AWACS to confirm if Guest requests and damage details are recorded
- 3 samples of BP Estimate to confirm individual jobs (repair panel) and damage area is clearly marked on vehicle image',
    '1) AWAC (Appointment & Walk Around Checksheet) / e-CRB Tab
2) Repair order copy
3) Diagnosis Questionnaire
4) Floormat Installation condition
5) BP AWAC Sheet from Document Control Board
6) BP Estimate Copy
7) iConnect App',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ027',
    'v1-DQ027-004',
    'Operation [Service]',
    'Service Reception',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Operation [Service]',
    'Service Reception',
    'GEM Service Plans the job in SMB (Chip and provided accurate delivery time to Guest. In case of BP, repair plan is done after insurance approval & delivery time is informed to guest.)',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Direct',
    '3S',
    'GEM Service Plans the job in SMB (Chip and provided accurate delivery time to Guest. In case of BP, repair plan is done after insurance approval & delivery time is informed to guest.)',
    '* Enable staff to make appropriate diagnosis &  propose for repair / maintenance.

* Prevent accidents result from improper usage of floor mats

* To ensure that accurate job instructions are provided by accurately confirming Guests’ requests and ensuring there are no oversights 

* To take care of Guest vehicle and the valuables',
    '1) Observe reception Process of at least 1 GS & 1 BP vehicle and confirm the following
- Guests are greeted on arrival by service staff and offered seat and preferred beverage
- Check if Guests are received by GEM Service immediately on arrival (not more 5 mins for appointment & on-time arrival guest & 10 mins for other guests. Arriving with in  +/- 15 mins from planned appointment time is considered as on-time arrival)
- Is the CGT time available at reception for General Repair requiring diagnosis.
- Check whether Floor Mat installation condition (lock, Non-Genuine, Multiple floor mats etc.) is  recorded in AWACS and informed to Guest.
- Check if tire & battery condition is checked using the recommended tools, TGloss requirement is assessed based on the vehicle condition and right value chain products are offered to guest.
- iConnect App is used when necessary to explain the service features and value chain products
2) Check the following documents and confirm if the guest requests, Service/repair/damage details are recorded and guest approval is taken
- 3 sample in GS: AWACS[Non-eCRB], Repair Order (RO), Diagnostic Questionnaire (DQ)
- 3 samples of B&P AWACS to confirm if Guest requests and damage details are recorded
- 3 samples of BP Estimate to confirm individual jobs (repair panel) and damage area is clearly marked on vehicle image',
    '1) AWAC (Appointment & Walk Around Checksheet) / e-CRB Tab
2) Repair order copy
3) Diagnosis Questionnaire
4) Floormat Installation condition
5) BP AWAC Sheet from Document Control Board
6) BP Estimate Copy
7) iConnect App',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ027',
    'v1-DQ027-005',
    'Operation [Service]',
    'Service Reception',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Operation [Service]',
    'Service Reception',
    'Floormat condition check by GEM (Service & explain guest about safety risk associated with unlocked / non-genuine floor mats / Multiple Floor Mats)',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Direct',
    '3S',
    'Floormat condition check by GEM (Service & explain guest about safety risk associated with unlocked / non-genuine floor mats / Multiple Floor Mats)',
    '* Enable staff to make appropriate diagnosis &  propose for repair / maintenance.

* Prevent accidents result from improper usage of floor mats

* To ensure that accurate job instructions are provided by accurately confirming Guests’ requests and ensuring there are no oversights 

* To take care of Guest vehicle and the valuables',
    '1) Observe reception Process of at least 1 GS & 1 BP vehicle and confirm the following
- Guests are greeted on arrival by service staff and offered seat and preferred beverage
- Check if Guests are received by GEM Service immediately on arrival (not more 5 mins for appointment & on-time arrival guest & 10 mins for other guests. Arriving with in  +/- 15 mins from planned appointment time is considered as on-time arrival)
- Is the CGT time available at reception for General Repair requiring diagnosis.
- Check whether Floor Mat installation condition (lock, Non-Genuine, Multiple floor mats etc.) is  recorded in AWACS and informed to Guest.
- Check if tire & battery condition is checked using the recommended tools, TGloss requirement is assessed based on the vehicle condition and right value chain products are offered to guest.
- iConnect App is used when necessary to explain the service features and value chain products
2) Check the following documents and confirm if the guest requests, Service/repair/damage details are recorded and guest approval is taken
- 3 sample in GS: AWACS[Non-eCRB], Repair Order (RO), Diagnostic Questionnaire (DQ)
- 3 samples of B&P AWACS to confirm if Guest requests and damage details are recorded
- 3 samples of BP Estimate to confirm individual jobs (repair panel) and damage area is clearly marked on vehicle image',
    '1) AWAC (Appointment & Walk Around Checksheet) / e-CRB Tab
2) Repair order copy
3) Diagnosis Questionnaire
4) Floormat Installation condition
5) BP AWAC Sheet from Document Control Board
6) BP Estimate Copy
7) iConnect App',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ027',
    'v1-DQ027-006',
    'Operation [Service]',
    'Service Reception',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Operation [Service]',
    'Service Reception',
    'Installation of courtesy items (Paper Floor mat, Seat Cover, Gear Knob Cover, Steering Cover Etc…',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Direct',
    '3S',
    'Installation of courtesy items (Paper Floor mat, Seat Cover, Gear Knob Cover, Steering Cover Etc…',
    '* Enable staff to make appropriate diagnosis &  propose for repair / maintenance.

* Prevent accidents result from improper usage of floor mats

* To ensure that accurate job instructions are provided by accurately confirming Guests’ requests and ensuring there are no oversights 

* To take care of Guest vehicle and the valuables',
    '1) Observe reception Process of at least 1 GS & 1 BP vehicle and confirm the following
- Guests are greeted on arrival by service staff and offered seat and preferred beverage
- Check if Guests are received by GEM Service immediately on arrival (not more 5 mins for appointment & on-time arrival guest & 10 mins for other guests. Arriving with in  +/- 15 mins from planned appointment time is considered as on-time arrival)
- Is the CGT time available at reception for General Repair requiring diagnosis.
- Check whether Floor Mat installation condition (lock, Non-Genuine, Multiple floor mats etc.) is  recorded in AWACS and informed to Guest.
- Check if tire & battery condition is checked using the recommended tools, TGloss requirement is assessed based on the vehicle condition and right value chain products are offered to guest.
- iConnect App is used when necessary to explain the service features and value chain products
2) Check the following documents and confirm if the guest requests, Service/repair/damage details are recorded and guest approval is taken
- 3 sample in GS: AWACS[Non-eCRB], Repair Order (RO), Diagnostic Questionnaire (DQ)
- 3 samples of B&P AWACS to confirm if Guest requests and damage details are recorded
- 3 samples of BP Estimate to confirm individual jobs (repair panel) and damage area is clearly marked on vehicle image',
    '1) AWAC (Appointment & Walk Around Checksheet) / e-CRB Tab
2) Repair order copy
3) Diagnosis Questionnaire
4) Floormat Installation condition
5) BP AWAC Sheet from Document Control Board
6) BP Estimate Copy
7) iConnect App',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ027',
    'v1-DQ027-007',
    'Operation [Service]',
    'Service Reception',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Operation [Service]',
    'Service Reception',
    'Make note of valuable items available in car & inform to Guest (Handover to guest',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Direct',
    '3S',
    'Make note of valuable items available in car & inform to Guest (Handover to guest',
    '* Enable staff to make appropriate diagnosis &  propose for repair / maintenance.

* Prevent accidents result from improper usage of floor mats

* To ensure that accurate job instructions are provided by accurately confirming Guests’ requests and ensuring there are no oversights 

* To take care of Guest vehicle and the valuables',
    '1) Observe reception Process of at least 1 GS & 1 BP vehicle and confirm the following
- Guests are greeted on arrival by service staff and offered seat and preferred beverage
- Check if Guests are received by GEM Service immediately on arrival (not more 5 mins for appointment & on-time arrival guest & 10 mins for other guests. Arriving with in  +/- 15 mins from planned appointment time is considered as on-time arrival)
- Is the CGT time available at reception for General Repair requiring diagnosis.
- Check whether Floor Mat installation condition (lock, Non-Genuine, Multiple floor mats etc.) is  recorded in AWACS and informed to Guest.
- Check if tire & battery condition is checked using the recommended tools, TGloss requirement is assessed based on the vehicle condition and right value chain products are offered to guest.
- iConnect App is used when necessary to explain the service features and value chain products
2) Check the following documents and confirm if the guest requests, Service/repair/damage details are recorded and guest approval is taken
- 3 sample in GS: AWACS[Non-eCRB], Repair Order (RO), Diagnostic Questionnaire (DQ)
- 3 samples of B&P AWACS to confirm if Guest requests and damage details are recorded
- 3 samples of BP Estimate to confirm individual jobs (repair panel) and damage area is clearly marked on vehicle image',
    '1) AWAC (Appointment & Walk Around Checksheet) / e-CRB Tab
2) Repair order copy
3) Diagnosis Questionnaire
4) Floormat Installation condition
5) BP AWAC Sheet from Document Control Board
6) BP Estimate Copy
7) iConnect App',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ027',
    'v1-DQ027-008',
    'Operation [Service]',
    'Service Reception',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Operation [Service]',
    'Service Reception',
    'Estimate is created including all request of guests and estimated cost is informed to guest',
    'Does GEM Service ensure following points as part of Service Reception Process?',
    'Direct',
    '3S',
    'Estimate is created including all request of guests and estimated cost is informed to guest',
    '* Enable staff to make appropriate diagnosis &  propose for repair / maintenance.

* Prevent accidents result from improper usage of floor mats

* To ensure that accurate job instructions are provided by accurately confirming Guests’ requests and ensuring there are no oversights 

* To take care of Guest vehicle and the valuables',
    '1) Observe reception Process of at least 1 GS & 1 BP vehicle and confirm the following
- Guests are greeted on arrival by service staff and offered seat and preferred beverage
- Check if Guests are received by GEM Service immediately on arrival (not more 5 mins for appointment & on-time arrival guest & 10 mins for other guests. Arriving with in  +/- 15 mins from planned appointment time is considered as on-time arrival)
- Is the CGT time available at reception for General Repair requiring diagnosis.
- Check whether Floor Mat installation condition (lock, Non-Genuine, Multiple floor mats etc.) is  recorded in AWACS and informed to Guest.
- Check if tire & battery condition is checked using the recommended tools, TGloss requirement is assessed based on the vehicle condition and right value chain products are offered to guest.
- iConnect App is used when necessary to explain the service features and value chain products
2) Check the following documents and confirm if the guest requests, Service/repair/damage details are recorded and guest approval is taken
- 3 sample in GS: AWACS[Non-eCRB], Repair Order (RO), Diagnostic Questionnaire (DQ)
- 3 samples of B&P AWACS to confirm if Guest requests and damage details are recorded
- 3 samples of BP Estimate to confirm individual jobs (repair panel) and damage area is clearly marked on vehicle image',
    '1) AWAC (Appointment & Walk Around Checksheet) / e-CRB Tab
2) Repair order copy
3) Diagnosis Questionnaire
4) Floormat Installation condition
5) BP AWAC Sheet from Document Control Board
6) BP Estimate Copy
7) iConnect App',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ028',
    'v1-DQ028-001',
    'Operation [Seamless]',
    'Service Reception',
    '[SINGLE POINT OF CONTACT & PERSONALIZED SERVICE]
Does dealer has a GEM-Service as a single point of contact through out guest life cycle?',
    'Operation [Seamless]',
    'Service Reception',
    'Same GEM-Service assigned to the guest everytime during service.',
    '[SINGLE POINT OF CONTACT & PERSONALIZED SERVICE]
Does dealer has a GEM-Service as a single point of contact through out guest life cycle?',
    'Direct',
    '3S',
    'Same GEM-Service assigned to the guest everytime during service.',
    '*Ensuring the one-stop solution for guest convenience and offers the best value & products as per guest need.',
    '1) Check same GEM-Service assigned to the guest everytime during service. (check i-crop to confirm the assignment)
2) GEM-Service update guest preferences in "Pulse" dashboard and utilizes the same during interaction with guest to offer the personalized service
3) GEM-Service pitches for repurchase to eligible based on the UIO Lead criteria (3Yr / 60 K - Diesel ; 3Yr / 30K - Petrol), Capture the additional purchase needs or referrals, communicate the leads to GEM-sales through PULSE TOOL and introduce the Guest to GEM-Sales
4) GEM-Service pitches the Value chain products (Smiles+, Insurance, Extended Warranty/SAWA, Tire, Battery & Gloss Studio) based on the information in PULSE & actual condition of vehicle',
    '1) Check if the guest preferences are updated PULSE tool and the information is utilized while interacting with guest
2) Exceptions to be considered for change/ re-allocation of GEM-Service
- If Assigned GEM-Service is on leave, guest can be attended by other GEM-Service from the same team
- GEM-Service assigned to be changed / updated if Guest prefers any other GEM-Service or if there is role change for GEM Service.',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Service & Parts","Used Car","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ028',
    'v1-DQ028-002',
    'Operation [Seamless]',
    'Service Reception',
    '[SINGLE POINT OF CONTACT & PERSONALIZED SERVICE]
Does dealer has a GEM-Service as a single point of contact through out guest life cycle?',
    'Operation [Seamless]',
    'Service Reception',
    'GEM-Service update guest preferences in "Pulse" dashboard and utilized during the guest interaction to offer the personalized service.',
    '[SINGLE POINT OF CONTACT & PERSONALIZED SERVICE]
Does dealer has a GEM-Service as a single point of contact through out guest life cycle?',
    'Direct',
    '3S',
    'GEM-Service update guest preferences in "Pulse" dashboard and utilized during the guest interaction to offer the personalized service.',
    '*Ensuring the one-stop solution for guest convenience and offers the best value & products as per guest need.',
    '1) Check same GEM-Service assigned to the guest everytime during service. (check i-crop to confirm the assignment)
2) GEM-Service update guest preferences in "Pulse" dashboard and utilizes the same during interaction with guest to offer the personalized service
3) GEM-Service pitches for repurchase to eligible based on the UIO Lead criteria (3Yr / 60 K - Diesel ; 3Yr / 30K - Petrol), Capture the additional purchase needs or referrals, communicate the leads to GEM-sales through PULSE TOOL and introduce the Guest to GEM-Sales
4) GEM-Service pitches the Value chain products (Smiles+, Insurance, Extended Warranty/SAWA, Tire, Battery & Gloss Studio) based on the information in PULSE & actual condition of vehicle',
    '1) Check if the guest preferences are updated PULSE tool and the information is utilized while interacting with guest
2) Exceptions to be considered for change/ re-allocation of GEM-Service
- If Assigned GEM-Service is on leave, guest can be attended by other GEM-Service from the same team
- GEM-Service assigned to be changed / updated if Guest prefers any other GEM-Service or if there is role change for GEM Service.',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Service & Parts","Used Car","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ028',
    'v1-DQ028-003',
    'Operation [Seamless]',
    'Service Reception',
    '[SINGLE POINT OF CONTACT & PERSONALIZED SERVICE]
Does dealer has a GEM-Service as a single point of contact through out guest life cycle?',
    'Operation [Seamless]',
    'Service Reception',
    'GEM-Service utlized "Pulse" tool to capture the lead for New car, Used Car and Value chain and pass the lead to concerned PIC through "Pulse" tool',
    '[SINGLE POINT OF CONTACT & PERSONALIZED SERVICE]
Does dealer has a GEM-Service as a single point of contact through out guest life cycle?',
    'Direct',
    '3S',
    'GEM-Service utlized "Pulse" tool to capture the lead for New car, Used Car and Value chain and pass the lead to concerned PIC through "Pulse" tool',
    '*Ensuring the one-stop solution for guest convenience and offers the best value & products as per guest need.',
    '1) Check same GEM-Service assigned to the guest everytime during service. (check i-crop to confirm the assignment)
2) GEM-Service update guest preferences in "Pulse" dashboard and utilizes the same during interaction with guest to offer the personalized service
3) GEM-Service pitches for repurchase to eligible based on the UIO Lead criteria (3Yr / 60 K - Diesel ; 3Yr / 30K - Petrol), Capture the additional purchase needs or referrals, communicate the leads to GEM-sales through PULSE TOOL and introduce the Guest to GEM-Sales
4) GEM-Service pitches the Value chain products (Smiles+, Insurance, Extended Warranty/SAWA, Tire, Battery & Gloss Studio) based on the information in PULSE & actual condition of vehicle',
    '1) Check if the guest preferences are updated PULSE tool and the information is utilized while interacting with guest
2) Exceptions to be considered for change/ re-allocation of GEM-Service
- If Assigned GEM-Service is on leave, guest can be attended by other GEM-Service from the same team
- GEM-Service assigned to be changed / updated if Guest prefers any other GEM-Service or if there is role change for GEM Service.',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales","Service & Parts","Used Car","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ029',
    'v1-DQ029-001',
    'Operation [Service]',
    'Service Reception',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Operation [Service]',
    'Service Reception',
    'Confirm if all the requested jobs are done on the vehicle.',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Direct',
    '3S',
    'Confirm if all the requested jobs are done on the vehicle.',
    '*To ensure all Guest requests are carried out and the vehicle is clean before Guest arrives

*To ensure Handover of Valuable items & approval of Guest

*To ensure Guest & GEM-Service signature on the Invoice so that all the work is done as per Guest satisfaction',
    '1) Check whether GEM-Service confirms the readiness of vehicle with final inspection check sheet record
2) B&P invoices to confirm whether labor and part are bifurcated separately and confirm Guest''s acknowledgement (In case of Insurance paid, confirm Delivery Order (DO) is attached).
3) Check 3 Repair Orders to note whether ready intimation communication to Guests recorded,
4) Check Sample of 3 repair invoice for GEM (Service)  & Guest Signature.
5) RO & Invoice copies signed by Guest to be stored for up to 3 years, to comply with local legal requirement.',
    '1) Final Inspection check sheet.
2) Communication log records with Insurance and Guest.
3) Document Control Board(DCB).
4) Invoice copy document
5) Delivery date commitment and adherence to the same',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ029',
    'v1-DQ029-002',
    'Operation [Service]',
    'Service Reception',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Operation [Service]',
    'Service Reception',
    'Confirms if the vehicle is clean and the floor mats are installed correctly and secured with locks, before delivering the vehicle to guest',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Direct',
    '3S',
    'Confirms if the vehicle is clean and the floor mats are installed correctly and secured with locks, before delivering the vehicle to guest',
    '*To ensure all Guest requests are carried out and the vehicle is clean before Guest arrives

*To ensure Handover of Valuable items & approval of Guest

*To ensure Guest & GEM-Service signature on the Invoice so that all the work is done as per Guest satisfaction',
    '1) Check whether GEM-Service confirms the readiness of vehicle with final inspection check sheet record
2) B&P invoices to confirm whether labor and part are bifurcated separately and confirm Guest''s acknowledgement (In case of Insurance paid, confirm Delivery Order (DO) is attached).
3) Check 3 Repair Orders to note whether ready intimation communication to Guests recorded,
4) Check Sample of 3 repair invoice for GEM (Service)  & Guest Signature.
5) RO & Invoice copies signed by Guest to be stored for up to 3 years, to comply with local legal requirement.',
    '1) Final Inspection check sheet.
2) Communication log records with Insurance and Guest.
3) Document Control Board(DCB).
4) Invoice copy document
5) Delivery date commitment and adherence to the same',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ029',
    'v1-DQ029-003',
    'Operation [Service]',
    'Service Reception',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Operation [Service]',
    'Service Reception',
    'Invoice preparation & explanation of work details and cost to the guest',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Direct',
    '3S',
    'Invoice preparation & explanation of work details and cost to the guest',
    '*To ensure all Guest requests are carried out and the vehicle is clean before Guest arrives

*To ensure Handover of Valuable items & approval of Guest

*To ensure Guest & GEM-Service signature on the Invoice so that all the work is done as per Guest satisfaction',
    '1) Check whether GEM-Service confirms the readiness of vehicle with final inspection check sheet record
2) B&P invoices to confirm whether labor and part are bifurcated separately and confirm Guest''s acknowledgement (In case of Insurance paid, confirm Delivery Order (DO) is attached).
3) Check 3 Repair Orders to note whether ready intimation communication to Guests recorded,
4) Check Sample of 3 repair invoice for GEM (Service)  & Guest Signature.
5) RO & Invoice copies signed by Guest to be stored for up to 3 years, to comply with local legal requirement.',
    '1) Final Inspection check sheet.
2) Communication log records with Insurance and Guest.
3) Document Control Board(DCB).
4) Invoice copy document
5) Delivery date commitment and adherence to the same',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ029',
    'v1-DQ029-004',
    'Operation [Service]',
    'Service Reception',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Operation [Service]',
    'Service Reception',
    'Explain the job done on the vehicle to the guest and confirm if the guest satisfied with work (problem resolution confirmation',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Direct',
    '3S',
    'Explain the job done on the vehicle to the guest and confirm if the guest satisfied with work (problem resolution confirmation',
    '*To ensure all Guest requests are carried out and the vehicle is clean before Guest arrives

*To ensure Handover of Valuable items & approval of Guest

*To ensure Guest & GEM-Service signature on the Invoice so that all the work is done as per Guest satisfaction',
    '1) Check whether GEM-Service confirms the readiness of vehicle with final inspection check sheet record
2) B&P invoices to confirm whether labor and part are bifurcated separately and confirm Guest''s acknowledgement (In case of Insurance paid, confirm Delivery Order (DO) is attached).
3) Check 3 Repair Orders to note whether ready intimation communication to Guests recorded,
4) Check Sample of 3 repair invoice for GEM (Service)  & Guest Signature.
5) RO & Invoice copies signed by Guest to be stored for up to 3 years, to comply with local legal requirement.',
    '1) Final Inspection check sheet.
2) Communication log records with Insurance and Guest.
3) Document Control Board(DCB).
4) Invoice copy document
5) Delivery date commitment and adherence to the same',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ029',
    'v1-DQ029-005',
    'Operation [Service]',
    'Service Reception',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Operation [Service]',
    'Service Reception',
    'All valuable items [Noted during Reception] & Replaced parts (if guest wants to see hand-over to Guest. Ensure to remove the tags (Price Name & Other Sensitive information from the carton box.)',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Direct',
    '3S',
    'All valuable items [Noted during Reception] & Replaced parts (if guest wants to see hand-over to Guest. Ensure to remove the tags (Price Name & Other Sensitive information from the carton box.)',
    '*To ensure all Guest requests are carried out and the vehicle is clean before Guest arrives

*To ensure Handover of Valuable items & approval of Guest

*To ensure Guest & GEM-Service signature on the Invoice so that all the work is done as per Guest satisfaction',
    '1) Check whether GEM-Service confirms the readiness of vehicle with final inspection check sheet record
2) B&P invoices to confirm whether labor and part are bifurcated separately and confirm Guest''s acknowledgement (In case of Insurance paid, confirm Delivery Order (DO) is attached).
3) Check 3 Repair Orders to note whether ready intimation communication to Guests recorded,
4) Check Sample of 3 repair invoice for GEM (Service)  & Guest Signature.
5) RO & Invoice copies signed by Guest to be stored for up to 3 years, to comply with local legal requirement.',
    '1) Final Inspection check sheet.
2) Communication log records with Insurance and Guest.
3) Document Control Board(DCB).
4) Invoice copy document
5) Delivery date commitment and adherence to the same',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ029',
    'v1-DQ029-006',
    'Operation [Service]',
    'Service Reception',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Operation [Service]',
    'Service Reception',
    'Escort the guest to the car and see of from the delivery bay',
    'Does GEM-Service perform delivery preparation process before delivering vehicle to Guest?',
    'Direct',
    '3S',
    'Escort the guest to the car and see of from the delivery bay',
    '*To ensure all Guest requests are carried out and the vehicle is clean before Guest arrives

*To ensure Handover of Valuable items & approval of Guest

*To ensure Guest & GEM-Service signature on the Invoice so that all the work is done as per Guest satisfaction',
    '1) Check whether GEM-Service confirms the readiness of vehicle with final inspection check sheet record
2) B&P invoices to confirm whether labor and part are bifurcated separately and confirm Guest''s acknowledgement (In case of Insurance paid, confirm Delivery Order (DO) is attached).
3) Check 3 Repair Orders to note whether ready intimation communication to Guests recorded,
4) Check Sample of 3 repair invoice for GEM (Service)  & Guest Signature.
5) RO & Invoice copies signed by Guest to be stored for up to 3 years, to comply with local legal requirement.',
    '1) Final Inspection check sheet.
2) Communication log records with Insurance and Guest.
3) Document Control Board(DCB).
4) Invoice copy document
5) Delivery date commitment and adherence to the same',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ030',
    'v1-DQ030-001',
    'Operation [Service]',
    'Service Back Office',
    '[Job progress management]
Does dealer visualizes and manages the progress of vehicle status through Document Control Board usage or Similar Control Tool [CS Board, BP SMB etc.]?',
    'Operation [Service]',
    'Service Back Office',
    'Job progress of all received vehicles can be confirmed immediately through any control board or system.',
    '[Job progress management]
Does dealer visualizes and manages the progress of vehicle status through Document Control Board usage or Similar Control Tool [CS Board, BP SMB etc.]?',
    'Indirect',
    '3S',
    'Job progress of all received vehicles can be confirmed immediately through any control board or system.',
    '*To avoid longer operation delay''s, It is important to visualize the Vehicle status and monitor the process irregularities.

*To avoid oversights or omission of process of any received vehicles.',
    '1) Confirm whether job progress of all received vehicles can be confirmed immediately by reception staff (GEM Service)
2) Check whether Process control board / Document Control Board (or similar control tool) is divided by job status such as "Appointment" "waiting for estimation", "waiting for parts" “ready for service" "Waiting delivery" posts like wise and managed accordingly,
3) Check whether all irregularities such as "no-shows", "waiting for approval"  like wise, are visualized using posts or documents',
    '1) Document Control Board (DCB) / Vehicle Status Monitoring Dashboard 
2) Standard operation guidelines for DCB  with Person In-Charge display.
3) Irregularity standards are visualized clearly (timelines).
4) Visually confirm the usage of DCB/ Process monitoring excel tool with actual condition.',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ030',
    'v1-DQ030-002',
    'Operation [Service]',
    'Service Back Office',
    '[Job progress management]
Does dealer visualizes and manages the progress of vehicle status through Document Control Board usage or Similar Control Tool [CS Board, BP SMB etc.]?',
    'Operation [Service]',
    'Service Back Office',
    'Vehicle job status such as "Appointment", "Waiting for Parts", "Ready for Service", "Waiting for Delivery" etc.. and irregularities, "No Shows", "Job Stoppage" are clearly visible and managed.',
    '[Job progress management]
Does dealer visualizes and manages the progress of vehicle status through Document Control Board usage or Similar Control Tool [CS Board, BP SMB etc.]?',
    'Indirect',
    '3S',
    'Vehicle job status such as "Appointment", "Waiting for Parts", "Ready for Service", "Waiting for Delivery" etc.. and irregularities, "No Shows", "Job Stoppage" are clearly visible and managed.',
    '*To avoid longer operation delay''s, It is important to visualize the Vehicle status and monitor the process irregularities.

*To avoid oversights or omission of process of any received vehicles.',
    '1) Confirm whether job progress of all received vehicles can be confirmed immediately by reception staff (GEM Service)
2) Check whether Process control board / Document Control Board (or similar control tool) is divided by job status such as "Appointment" "waiting for estimation", "waiting for parts" “ready for service" "Waiting delivery" posts like wise and managed accordingly,
3) Check whether all irregularities such as "no-shows", "waiting for approval"  like wise, are visualized using posts or documents',
    '1) Document Control Board (DCB) / Vehicle Status Monitoring Dashboard 
2) Standard operation guidelines for DCB  with Person In-Charge display.
3) Irregularity standards are visualized clearly (timelines).
4) Visually confirm the usage of DCB/ Process monitoring excel tool with actual condition.',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ031',
    'v1-DQ031-001',
    'Operation [Service]',
    'Service Back Office',
    '[Repair Quality management]
Does dealer performs quality check as per distributor guidelines?',
    'Operation [Service]',
    'Service Back Office',
    'Quality Gate materials are used to monitor and visualize all the quality gates & its processes.',
    '[Repair Quality management]
Does dealer performs quality check as per distributor guidelines?',
    'Indirect',
    '3S',
    'Quality Gate materials are used to monitor and visualize all the quality gates & its processes.',
    '* Ensure all the jobs are completed with Quality.

* Ensure critical jobs / issues are informed to Guest through QC Comments.',
    '1) Check availability of quality gate inspection result and visualization 
2) Sample check 5 RO''s on the JPCB (Job Progress Control Board) whether the skill level matches as per mention in technical skill map.
3) Interview with Job Controller, CGT(TA) & Washing Supervisor to check their usage of quality gate inspection.
4) [FIR] Check the utilization of In-process confirmation check sheets for GEM (Service), CGT & Technician process (TSM-FIR Module 2)',
    '1) Quality Gate Sheet*, 
2) Technician Skill Matrix (Updated every month - Ideal)
3) Quality Gate Visualizations & analysis,
4) Quality Gate Review and action Plans
5) FIR & TSM FIR Obheya 

* Last one month records
*Refer Annexure 1 & 2 for e-CRB iPad dealers',
    '1) TSM FIR Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ031',
    'v1-DQ031-002',
    'Operation [Service]',
    'Service Back Office',
    '[Repair Quality management]
Does dealer performs quality check as per distributor guidelines?',
    'Operation [Service]',
    'Service Back Office',
    'Availability of updated technical skill map at the jobs allocation area & allocation of work as per technician skill matrix',
    '[Repair Quality management]
Does dealer performs quality check as per distributor guidelines?',
    'Indirect',
    '3S',
    'Availability of updated technical skill map at the jobs allocation area & allocation of work as per technician skill matrix',
    '* Ensure all the jobs are completed with Quality.

* Ensure critical jobs / issues are informed to Guest through QC Comments.',
    '1) Check availability of quality gate inspection result and visualization 
2) Sample check 5 RO''s on the JPCB (Job Progress Control Board) whether the skill level matches as per mention in technical skill map.
3) Interview with Job Controller, CGT(TA) & Washing Supervisor to check their usage of quality gate inspection.
4) [FIR] Check the utilization of In-process confirmation check sheets for GEM (Service), CGT & Technician process (TSM-FIR Module 2)',
    '1) Quality Gate Sheet*, 
2) Technician Skill Matrix (Updated every month - Ideal)
3) Quality Gate Visualizations & analysis,
4) Quality Gate Review and action Plans
5) FIR & TSM FIR Obheya 

* Last one month records
*Refer Annexure 1 & 2 for e-CRB iPad dealers',
    '1) TSM FIR Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  );

INSERT INTO audit_checklist_master (
  checklist_code,
  version,
  section,
  area,
  chapter,
  classification,
  location_aspect,
  evaluation_question,
  evaluation_parameter,
  guest_experience_impact,
  facility_type,
  question,
  purpose,
  checking_method,
  additional_info,
  sop_reference,
  evidence_required,
  applicable_departments,
  status
) VALUES
(
    'DQ031',
    'v1-DQ031-003',
    'Operation [Service]',
    'Service Back Office',
    '[Repair Quality management]
Does dealer performs quality check as per distributor guidelines?',
    'Operation [Service]',
    'Service Back Office',
    'Continuous review of Quality gate defects are carried out and appropriate action is taken',
    '[Repair Quality management]
Does dealer performs quality check as per distributor guidelines?',
    'Indirect',
    '3S',
    'Continuous review of Quality gate defects are carried out and appropriate action is taken',
    '* Ensure all the jobs are completed with Quality.

* Ensure critical jobs / issues are informed to Guest through QC Comments.',
    '1) Check availability of quality gate inspection result and visualization 
2) Sample check 5 RO''s on the JPCB (Job Progress Control Board) whether the skill level matches as per mention in technical skill map.
3) Interview with Job Controller, CGT(TA) & Washing Supervisor to check their usage of quality gate inspection.
4) [FIR] Check the utilization of In-process confirmation check sheets for GEM (Service), CGT & Technician process (TSM-FIR Module 2)',
    '1) Quality Gate Sheet*, 
2) Technician Skill Matrix (Updated every month - Ideal)
3) Quality Gate Visualizations & analysis,
4) Quality Gate Review and action Plans
5) FIR & TSM FIR Obheya 

* Last one month records
*Refer Annexure 1 & 2 for e-CRB iPad dealers',
    '1) TSM FIR Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ031',
    'v1-DQ031-004',
    'Operation [Service]',
    'Service Back Office',
    '[Repair Quality management]
Does dealer performs quality check as per distributor guidelines?',
    'Operation [Service]',
    'Service Back Office',
    'Audit of GEM-Service, CGT & Technicians by their respective team leaders to check SOP Adherence & RCA on gap areas (TSM-FIR Module 2',
    '[Repair Quality management]
Does dealer performs quality check as per distributor guidelines?',
    'Indirect',
    '3S',
    'Audit of GEM-Service, CGT & Technicians by their respective team leaders to check SOP Adherence & RCA on gap areas (TSM-FIR Module 2',
    '* Ensure all the jobs are completed with Quality.

* Ensure critical jobs / issues are informed to Guest through QC Comments.',
    '1) Check availability of quality gate inspection result and visualization 
2) Sample check 5 RO''s on the JPCB (Job Progress Control Board) whether the skill level matches as per mention in technical skill map.
3) Interview with Job Controller, CGT(TA) & Washing Supervisor to check their usage of quality gate inspection.
4) [FIR] Check the utilization of In-process confirmation check sheets for GEM (Service), CGT & Technician process (TSM-FIR Module 2)',
    '1) Quality Gate Sheet*, 
2) Technician Skill Matrix (Updated every month - Ideal)
3) Quality Gate Visualizations & analysis,
4) Quality Gate Review and action Plans
5) FIR & TSM FIR Obheya 

* Last one month records
*Refer Annexure 1 & 2 for e-CRB iPad dealers',
    '1) TSM FIR Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ032',
    'v1-DQ032-001',
    'Operation [Service]',
    'Service Back Office',
    '[Production management]
Does dealer manages and visualizes the status of repair work accurately in SMB (JPCB if e-CRB not implemented) and in vehicle?',
    'Operation [Service]',
    'Service Back Office',
    'Status of vehicle progress is clearly visible in SMB/JPCB and status hanger.',
    '[Production management]
Does dealer manages and visualizes the status of repair work accurately in SMB (JPCB if e-CRB not implemented) and in vehicle?',
    'Indirect',
    '3S',
    'Status of vehicle progress is clearly visible in SMB/JPCB and status hanger.',
    '* To ensure the on-time delivery of the vehicle

* To improve the workshop productivity through planning and Muda reduction',
    '1) Check vehicle status is updated in the SMB / JPCB and in vehicle with Status hanger
2) Status in the status hanger matches with that of SMB / GEM (Service)  i-Pad 
3) Status in SMB / GEM-Service i-Pad matches with actual condition of the vehicle (waiting for allocation, work in-progress, waiting for next process, job stop, work completed etc.)
4) Additional job requirement / Job stoppage status & reason is updated in SMB
5) Vehicles are parked in the designated parking as per the status updated in SMB & status hanger (parking to be designated as per service status) SMB / JPCB-GS & RSB / BP-SMB
6) Additional Job requirement and change in the cost & delivery time is communicated to Guest (interview staff about the Guest communication process for job stoppage / additional job requirement vehicles)
7) Reason for delivery time change / delay in delivery is clearly explained to the guest',
    '1) Check at least 5 chips in SMB and status hanger in the related vehicles
2) Check all the Job stop chips in the SMB, and interview JC / GEM Service (both GS & BP area)',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ032',
    'v1-DQ032-002',
    'Operation [Service]',
    'Service Back Office',
    '[Production management]
Does dealer manages and visualizes the status of repair work accurately in SMB (JPCB if e-CRB not implemented) and in vehicle?',
    'Operation [Service]',
    'Service Back Office',
    'Vehicle parked is deignated parking bay and status is updated in status hanger.',
    '[Production management]
Does dealer manages and visualizes the status of repair work accurately in SMB (JPCB if e-CRB not implemented) and in vehicle?',
    'Indirect',
    '3S',
    'Vehicle parked is deignated parking bay and status is updated in status hanger.',
    '* To ensure the on-time delivery of the vehicle

* To improve the workshop productivity through planning and Muda reduction',
    '1) Check vehicle status is updated in the SMB / JPCB and in vehicle with Status hanger
2) Status in the status hanger matches with that of SMB / GEM (Service)  i-Pad 
3) Status in SMB / GEM-Service i-Pad matches with actual condition of the vehicle (waiting for allocation, work in-progress, waiting for next process, job stop, work completed etc.)
4) Additional job requirement / Job stoppage status & reason is updated in SMB
5) Vehicles are parked in the designated parking as per the status updated in SMB & status hanger (parking to be designated as per service status) SMB / JPCB-GS & RSB / BP-SMB
6) Additional Job requirement and change in the cost & delivery time is communicated to Guest (interview staff about the Guest communication process for job stoppage / additional job requirement vehicles)
7) Reason for delivery time change / delay in delivery is clearly explained to the guest',
    '1) Check at least 5 chips in SMB and status hanger in the related vehicles
2) Check all the Job stop chips in the SMB, and interview JC / GEM Service (both GS & BP area)',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ032',
    'v1-DQ032-003',
    'Operation [Service]',
    'Service Back Office',
    '[Production management]
Does dealer manages and visualizes the status of repair work accurately in SMB (JPCB if e-CRB not implemented) and in vehicle?',
    'Operation [Service]',
    'Service Back Office',
    'Additional job requirement and change in cost & delivery time is communicated to guest.',
    '[Production management]
Does dealer manages and visualizes the status of repair work accurately in SMB (JPCB if e-CRB not implemented) and in vehicle?',
    'Indirect',
    '3S',
    'Additional job requirement and change in cost & delivery time is communicated to guest.',
    '* To ensure the on-time delivery of the vehicle

* To improve the workshop productivity through planning and Muda reduction',
    '1) Check vehicle status is updated in the SMB / JPCB and in vehicle with Status hanger
2) Status in the status hanger matches with that of SMB / GEM (Service)  i-Pad 
3) Status in SMB / GEM-Service i-Pad matches with actual condition of the vehicle (waiting for allocation, work in-progress, waiting for next process, job stop, work completed etc.)
4) Additional job requirement / Job stoppage status & reason is updated in SMB
5) Vehicles are parked in the designated parking as per the status updated in SMB & status hanger (parking to be designated as per service status) SMB / JPCB-GS & RSB / BP-SMB
6) Additional Job requirement and change in the cost & delivery time is communicated to Guest (interview staff about the Guest communication process for job stoppage / additional job requirement vehicles)
7) Reason for delivery time change / delay in delivery is clearly explained to the guest',
    '1) Check at least 5 chips in SMB and status hanger in the related vehicles
2) Check all the Job stop chips in the SMB, and interview JC / GEM Service (both GS & BP area)',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ032',
    'v1-DQ032-004',
    'Operation [Service]',
    'Service Back Office',
    '[Production management]
Does dealer manages and visualizes the status of repair work accurately in SMB (JPCB if e-CRB not implemented) and in vehicle?',
    'Operation [Service]',
    'Service Back Office',
    'Delivery time change or delay reason are captured and communicated to guest',
    '[Production management]
Does dealer manages and visualizes the status of repair work accurately in SMB (JPCB if e-CRB not implemented) and in vehicle?',
    'Indirect',
    '3S',
    'Delivery time change or delay reason are captured and communicated to guest',
    '* To ensure the on-time delivery of the vehicle

* To improve the workshop productivity through planning and Muda reduction',
    '1) Check vehicle status is updated in the SMB / JPCB and in vehicle with Status hanger
2) Status in the status hanger matches with that of SMB / GEM (Service)  i-Pad 
3) Status in SMB / GEM-Service i-Pad matches with actual condition of the vehicle (waiting for allocation, work in-progress, waiting for next process, job stop, work completed etc.)
4) Additional job requirement / Job stoppage status & reason is updated in SMB
5) Vehicles are parked in the designated parking as per the status updated in SMB & status hanger (parking to be designated as per service status) SMB / JPCB-GS & RSB / BP-SMB
6) Additional Job requirement and change in the cost & delivery time is communicated to Guest (interview staff about the Guest communication process for job stoppage / additional job requirement vehicles)
7) Reason for delivery time change / delay in delivery is clearly explained to the guest',
    '1) Check at least 5 chips in SMB and status hanger in the related vehicles
2) Check all the Job stop chips in the SMB, and interview JC / GEM Service (both GS & BP area)',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ033',
    'v1-DQ033-001',
    'Operation [Service]',
    'Service Back Office',
    'Does dealer has Work Sequence Sheet (WSS) or tools and utilized as per Standard operation procedure (SOP) defined by dealer or recommended by distributor?',
    'Operation [Service]',
    'Service Back Office',
    'Standard Operation Procedure (SOP Available & Utilized for all Standard Process)',
    'Does dealer has Work Sequence Sheet (WSS) or tools and utilized as per Standard operation procedure (SOP) defined by dealer or recommended by distributor?',
    'Indirect',
    '3S',
    'Standard Operation Procedure (SOP Available & Utilized for all Standard Process)',
    '* Ensure that all the jobs are done at the right time by the right person.

* Helps to visualize irregularities for timely action',
    '1) Check the tools (both manual & electronic ) and do random interview with both front office and shop floor staff on SOP understanding with adherence check
2) Check the Work Sequence Sheet (WSS) & SOP documents for the clear definition of "Go-ahead Instruction" & Interview the staff to confirm the same for critical Process
3) Check display of operating rule near Job planning tools, Progress / status visualization tools
4) Operating rules must include: “Timing or opportunity to operate tools”, “Operating procedure” and “Person in charge of operation”',
    '1) Both TKM supplied and dealer''s internal control tools should be covered. 
TKM recommended Visual Control Tools: 
- e-CRB i-pad dealers : i-PADS with all GEM Service, JC, Showroom Hostess / LIC, i-phone with security (if gate camera implemented) & washing supervisor,  with access to e-CRB
- e-CRB desktop dealers : SMB, JPCB, APB, Special Order Parts Rack, Parts Pre Pull Rack
2) Go-ahead instruction refers the ''trigger'' to start an action. Ex: Go-ahead for GEM-Service to start reception is notification in i-PAD based on assignment by Showroom Hostess. All processes from MRS & Appointment to Delivery must have go-ahead instruction defined in respective SOP',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ033',
    'v1-DQ033-002',
    'Operation [Service]',
    'Service Back Office',
    'Does dealer has Work Sequence Sheet (WSS) or tools and utilized as per Standard operation procedure (SOP) defined by dealer or recommended by distributor?',
    'Operation [Service]',
    'Service Back Office',
    'Operating rules availability & Adherence for all control tools with go-ahead instructions & prioritization rules for each process is clearly defined in the Work Sequence Sheet (WSS /SOP and implemented)',
    'Does dealer has Work Sequence Sheet (WSS) or tools and utilized as per Standard operation procedure (SOP) defined by dealer or recommended by distributor?',
    'Indirect',
    '3S',
    'Operating rules availability & Adherence for all control tools with go-ahead instructions & prioritization rules for each process is clearly defined in the Work Sequence Sheet (WSS /SOP and implemented)',
    '* Ensure that all the jobs are done at the right time by the right person.

* Helps to visualize irregularities for timely action',
    '1) Check the tools (both manual & electronic ) and do random interview with both front office and shop floor staff on SOP understanding with adherence check
2) Check the Work Sequence Sheet (WSS) & SOP documents for the clear definition of "Go-ahead Instruction" & Interview the staff to confirm the same for critical Process
3) Check display of operating rule near Job planning tools, Progress / status visualization tools
4) Operating rules must include: “Timing or opportunity to operate tools”, “Operating procedure” and “Person in charge of operation”',
    '1) Both TKM supplied and dealer''s internal control tools should be covered. 
TKM recommended Visual Control Tools: 
- e-CRB i-pad dealers : i-PADS with all GEM Service, JC, Showroom Hostess / LIC, i-phone with security (if gate camera implemented) & washing supervisor,  with access to e-CRB
- e-CRB desktop dealers : SMB, JPCB, APB, Special Order Parts Rack, Parts Pre Pull Rack
2) Go-ahead instruction refers the ''trigger'' to start an action. Ex: Go-ahead for GEM-Service to start reception is notification in i-PAD based on assignment by Showroom Hostess. All processes from MRS & Appointment to Delivery must have go-ahead instruction defined in respective SOP',
    '1) GS and BP Service SOP (Swayam Portal)
2) e-CRB SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ034',
    'v1-DQ034-001',
    'Facility',
    'Workshop',
    'Does dealer maintains the workshop in well maintained condition and equipped with the required space to ensure safe and productivity environment?',
    'Facility',
    'Workshop',
    'Work bays dimension and marking as per TKM standards',
    'Does dealer maintains the workshop in well maintained condition and equipped with the required space to ensure safe and productivity environment?',
    'Indirect',
    '3S',
    'Work bays dimension and marking as per TKM standards',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view. 

*These requirements help in running the service business smoothly & keep Guests happy.',
    'Check the following in workshop (production bays):
1) Bays are of standard dimensions (EM stall - 4m x 7m with Scissors Lift or 4.5m x 7m with two Post Lift; GR Bay - 4m x 7m, Frame Alignment bay - 5.5 x 8m, Washing bay 5 x 8 m)
2) Bays are clearly marked (Bay boundary, tools / trolley position) & there are no permanent obstacle (e.g. pillar etc.) in the bay.
3) Working stalls are in good condition (no broken tiles / epoxy) and 4S is done after every vehicle service (in case of oil spillage, clean immediately with saw dust to ensure safety).
4) EM bays are easily recognizable at glance (blue epoxy / tiles, EM Name Board display)
5) There are no obstacle in the movement path of technician within the bay (uneven surface, broken tiles / epoxy, air hose, tools / vehicle parts kept in bay)
6) Adequate lighting conditions in each working area/stall up to the following standards.',
    'In the Working stall area confirm the below 
1) Lift capacity greater than 3000 Kg ~ 4000 Kg
2) Minimum light intensity utilizing lux meter Is there adequate lighting in each stall up to the following standards (Measure Lux at respective stalls & under the hood in the working stall)
- General repair stall: 350 lux
- EM stall and BP Parts disassembly & reassembly: 500 lux
- Damage inspection, panel preparation and surface preparation stall: 700 lux  
- Frame repair stall : 750 lux
- Paint booth & polishing stall & Paint mixing Room 1000 lux             
- Final Inspection stall: 1500 lux',
    '1) DIVA guidelines (Workshop bay)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ034',
    'v1-DQ034-002',
    'Facility',
    'Workshop',
    'Does dealer maintains the workshop in well maintained condition and equipped with the required space to ensure safe and productivity environment?',
    'Facility',
    'Workshop',
    'Work bays, Gangway/Walk parth neatness and cleanliness',
    'Does dealer maintains the workshop in well maintained condition and equipped with the required space to ensure safe and productivity environment?',
    'Indirect',
    '3S',
    'Work bays, Gangway/Walk parth neatness and cleanliness',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view. 

*These requirements help in running the service business smoothly & keep Guests happy.',
    'Check the following in workshop (production bays):
1) Bays are of standard dimensions (EM stall - 4m x 7m with Scissors Lift or 4.5m x 7m with two Post Lift; GR Bay - 4m x 7m, Frame Alignment bay - 5.5 x 8m, Washing bay 5 x 8 m)
2) Bays are clearly marked (Bay boundary, tools / trolley position) & there are no permanent obstacle (e.g. pillar etc.) in the bay.
3) Working stalls are in good condition (no broken tiles / epoxy) and 4S is done after every vehicle service (in case of oil spillage, clean immediately with saw dust to ensure safety).
4) EM bays are easily recognizable at glance (blue epoxy / tiles, EM Name Board display)
5) There are no obstacle in the movement path of technician within the bay (uneven surface, broken tiles / epoxy, air hose, tools / vehicle parts kept in bay)
6) Adequate lighting conditions in each working area/stall up to the following standards.',
    'In the Working stall area confirm the below 
1) Lift capacity greater than 3000 Kg ~ 4000 Kg
2) Minimum light intensity utilizing lux meter Is there adequate lighting in each stall up to the following standards (Measure Lux at respective stalls & under the hood in the working stall)
- General repair stall: 350 lux
- EM stall and BP Parts disassembly & reassembly: 500 lux
- Damage inspection, panel preparation and surface preparation stall: 700 lux  
- Frame repair stall : 750 lux
- Paint booth & polishing stall & Paint mixing Room 1000 lux             
- Final Inspection stall: 1500 lux',
    '1) DIVA guidelines (Workshop bay)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ034',
    'v1-DQ034-003',
    'Facility',
    'Workshop',
    'Does dealer maintains the workshop in well maintained condition and equipped with the required space to ensure safe and productivity environment?',
    'Facility',
    'Workshop',
    'No obstacles in vehicle and man movement areas',
    'Does dealer maintains the workshop in well maintained condition and equipped with the required space to ensure safe and productivity environment?',
    'Indirect',
    '3S',
    'No obstacles in vehicle and man movement areas',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view. 

*These requirements help in running the service business smoothly & keep Guests happy.',
    'Check the following in workshop (production bays):
1) Bays are of standard dimensions (EM stall - 4m x 7m with Scissors Lift or 4.5m x 7m with two Post Lift; GR Bay - 4m x 7m, Frame Alignment bay - 5.5 x 8m, Washing bay 5 x 8 m)
2) Bays are clearly marked (Bay boundary, tools / trolley position) & there are no permanent obstacle (e.g. pillar etc.) in the bay.
3) Working stalls are in good condition (no broken tiles / epoxy) and 4S is done after every vehicle service (in case of oil spillage, clean immediately with saw dust to ensure safety).
4) EM bays are easily recognizable at glance (blue epoxy / tiles, EM Name Board display)
5) There are no obstacle in the movement path of technician within the bay (uneven surface, broken tiles / epoxy, air hose, tools / vehicle parts kept in bay)
6) Adequate lighting conditions in each working area/stall up to the following standards.',
    'In the Working stall area confirm the below 
1) Lift capacity greater than 3000 Kg ~ 4000 Kg
2) Minimum light intensity utilizing lux meter Is there adequate lighting in each stall up to the following standards (Measure Lux at respective stalls & under the hood in the working stall)
- General repair stall: 350 lux
- EM stall and BP Parts disassembly & reassembly: 500 lux
- Damage inspection, panel preparation and surface preparation stall: 700 lux  
- Frame repair stall : 750 lux
- Paint booth & polishing stall & Paint mixing Room 1000 lux             
- Final Inspection stall: 1500 lux',
    '1) DIVA guidelines (Workshop bay)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ034',
    'v1-DQ034-004',
    'Facility',
    'Workshop',
    'Does dealer maintains the workshop in well maintained condition and equipped with the required space to ensure safe and productivity environment?',
    'Facility',
    'Workshop',
    'Adequate lightining all work bay areas as per TKM standards',
    'Does dealer maintains the workshop in well maintained condition and equipped with the required space to ensure safe and productivity environment?',
    'Indirect',
    '3S',
    'Adequate lightining all work bay areas as per TKM standards',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view. 

*These requirements help in running the service business smoothly & keep Guests happy.',
    'Check the following in workshop (production bays):
1) Bays are of standard dimensions (EM stall - 4m x 7m with Scissors Lift or 4.5m x 7m with two Post Lift; GR Bay - 4m x 7m, Frame Alignment bay - 5.5 x 8m, Washing bay 5 x 8 m)
2) Bays are clearly marked (Bay boundary, tools / trolley position) & there are no permanent obstacle (e.g. pillar etc.) in the bay.
3) Working stalls are in good condition (no broken tiles / epoxy) and 4S is done after every vehicle service (in case of oil spillage, clean immediately with saw dust to ensure safety).
4) EM bays are easily recognizable at glance (blue epoxy / tiles, EM Name Board display)
5) There are no obstacle in the movement path of technician within the bay (uneven surface, broken tiles / epoxy, air hose, tools / vehicle parts kept in bay)
6) Adequate lighting conditions in each working area/stall up to the following standards.',
    'In the Working stall area confirm the below 
1) Lift capacity greater than 3000 Kg ~ 4000 Kg
2) Minimum light intensity utilizing lux meter Is there adequate lighting in each stall up to the following standards (Measure Lux at respective stalls & under the hood in the working stall)
- General repair stall: 350 lux
- EM stall and BP Parts disassembly & reassembly: 500 lux
- Damage inspection, panel preparation and surface preparation stall: 700 lux  
- Frame repair stall : 750 lux
- Paint booth & polishing stall & Paint mixing Room 1000 lux             
- Final Inspection stall: 1500 lux',
    '1) DIVA guidelines (Workshop bay)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ035',
    'v1-DQ035-001',
    'Facility',
    'Workshop',
    'Does dealer has the Availability & Usage of the following tools/equipment in general service workshop as per TKM Recommendation?',
    'Facility',
    'Workshop',
    'Availability of tools/equipment',
    'Does dealer has the Availability & Usage of the following tools/equipment in general service workshop as per TKM Recommendation?',
    'Indirect',
    '3S',
    'Availability of tools/equipment',
    '*Toyota standards  tools / equipment & courtesy items should be available  for technician convenience & safety, quality & speed of repairs and to take care of vehicle

*Availability of the Above will Ensure Guest satisfaction',
    'Check the below items
1) Tools & equipment in working condition & regular 4S is done by technician (recommended to do regular calibration in case of torque wrench, critical torquing tools & 4S at end of the day)
2) SST availability in good condition and compare with TKM / Alliance latest SST list
3) Availability of EM efficiency enhancing equipment in good condition in EM bay and its usage by technicians and must have lifts that can handle heavist vehicle in the market. Eg: EM trolley, LLC, Etc..
4) Tools inspection check list & record of periodic inspection of the tools (check the tools availability & working condition at least once a quarter)
5) Quality parameter (Periodic calibration) for Wheel balancer, Wheel Aligner, A/c filling, etc.
6) Check for Periodic Maintenance Plan & AMC, Parts replacement as per recommendation, Breakdown countermeasure closing cycle.
7) Check availability of Daily Pre-operation check sheet for abnormality escalation & closing.',
    'Following items need to be checked:
1) Basic hand tools for all GR bays
2) Basic EM bay tools (For each EM trolley)
3) EM efficiency equipment - EM system trolley (including air tools), LLC trolley, Oil drain trolley,  Differential Oil filler & Tire trolley
4) GTS & SDT
5) General service equipment (Rigid racks, Engine & Transmission jacks, Service Clippers, Testers ) 
6) Work Bench
7) SST [Refer latest Tools,  SST , equipment guide from TKM]

Note : LLC : Long Life Coolant',
    '1) Tools & Equipment (EM Bay)
2) EM Efficiency Equipment Annexure',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ035',
    'v1-DQ035-002',
    'Facility',
    'Workshop',
    'Does dealer has the Availability & Usage of the following tools/equipment in general service workshop as per TKM Recommendation?',
    'Facility',
    'Workshop',
    'Availability of SST (Special Service Tool',
    'Does dealer has the Availability & Usage of the following tools/equipment in general service workshop as per TKM Recommendation?',
    'Indirect',
    '3S',
    'Availability of SST (Special Service Tool',
    '*Toyota standards  tools / equipment & courtesy items should be available  for technician convenience & safety, quality & speed of repairs and to take care of vehicle

*Availability of the Above will Ensure Guest satisfaction',
    'Check the below items
1) Tools & equipment in working condition & regular 4S is done by technician (recommended to do regular calibration in case of torque wrench, critical torquing tools & 4S at end of the day)
2) SST availability in good condition and compare with TKM / Alliance latest SST list
3) Availability of EM efficiency enhancing equipment in good condition in EM bay and its usage by technicians and must have lifts that can handle heavist vehicle in the market. Eg: EM trolley, LLC, Etc..
4) Tools inspection check list & record of periodic inspection of the tools (check the tools availability & working condition at least once a quarter)
5) Quality parameter (Periodic calibration) for Wheel balancer, Wheel Aligner, A/c filling, etc.
6) Check for Periodic Maintenance Plan & AMC, Parts replacement as per recommendation, Breakdown countermeasure closing cycle.
7) Check availability of Daily Pre-operation check sheet for abnormality escalation & closing.',
    'Following items need to be checked:
1) Basic hand tools for all GR bays
2) Basic EM bay tools (For each EM trolley)
3) EM efficiency equipment - EM system trolley (including air tools), LLC trolley, Oil drain trolley,  Differential Oil filler & Tire trolley
4) GTS & SDT
5) General service equipment (Rigid racks, Engine & Transmission jacks, Service Clippers, Testers ) 
6) Work Bench
7) SST [Refer latest Tools,  SST , equipment guide from TKM]

Note : LLC : Long Life Coolant',
    '1) Tools & Equipment (EM Bay)
2) EM Efficiency Equipment Annexure',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ035',
    'v1-DQ035-003',
    'Facility',
    'Workshop',
    'Does dealer has the Availability & Usage of the following tools/equipment in general service workshop as per TKM Recommendation?',
    'Facility',
    'Workshop',
    'All Equipment are periodically maintained [e.g.: Two post lift, Wheel balancing machine, A/C gas refilling machine, Wheel Aligner etc.]',
    'Does dealer has the Availability & Usage of the following tools/equipment in general service workshop as per TKM Recommendation?',
    'Indirect',
    '3S',
    'All Equipment are periodically maintained [e.g.: Two post lift, Wheel balancing machine, A/C gas refilling machine, Wheel Aligner etc.]',
    '*Toyota standards  tools / equipment & courtesy items should be available  for technician convenience & safety, quality & speed of repairs and to take care of vehicle

*Availability of the Above will Ensure Guest satisfaction',
    'Check the below items
1) Tools & equipment in working condition & regular 4S is done by technician (recommended to do regular calibration in case of torque wrench, critical torquing tools & 4S at end of the day)
2) SST availability in good condition and compare with TKM / Alliance latest SST list
3) Availability of EM efficiency enhancing equipment in good condition in EM bay and its usage by technicians and must have lifts that can handle heavist vehicle in the market. Eg: EM trolley, LLC, Etc..
4) Tools inspection check list & record of periodic inspection of the tools (check the tools availability & working condition at least once a quarter)
5) Quality parameter (Periodic calibration) for Wheel balancer, Wheel Aligner, A/c filling, etc.
6) Check for Periodic Maintenance Plan & AMC, Parts replacement as per recommendation, Breakdown countermeasure closing cycle.
7) Check availability of Daily Pre-operation check sheet for abnormality escalation & closing.',
    'Following items need to be checked:
1) Basic hand tools for all GR bays
2) Basic EM bay tools (For each EM trolley)
3) EM efficiency equipment - EM system trolley (including air tools), LLC trolley, Oil drain trolley,  Differential Oil filler & Tire trolley
4) GTS & SDT
5) General service equipment (Rigid racks, Engine & Transmission jacks, Service Clippers, Testers ) 
6) Work Bench
7) SST [Refer latest Tools,  SST , equipment guide from TKM]

Note : LLC : Long Life Coolant',
    '1) Tools & Equipment (EM Bay)
2) EM Efficiency Equipment Annexure',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ036',
    'v1-DQ036-001',
    'Operation [Service]',
    'Workshop',
    'Does dealer has updated EM Menu and SWP as per market requirement recommended by Distributor guidelines?',
    'Operation [Service]',
    'Workshop',
    'EM menu is prepared to covers at least 50% of PM units (including additional jobs and covers 40k service of the models mentioned in the menu)',
    'Does dealer has updated EM Menu and SWP as per market requirement recommended by Distributor guidelines?',
    'Indirect',
    '3S',
    'EM menu is prepared to covers at least 50% of PM units (including additional jobs and covers 40k service of the models mentioned in the menu)',
    '*EM work procedures are designed for three man operation keeping in mind the minimum walking/waiting etc. of the technicians. Only when these procedures are defined correctly & followed, can the shorter lead times be achieved.

*In order to carry out a safe, high quality service & repair, it is essential to follow the TMC recommendations during vehicle servicing.',
    '1) Check for existence & usage of  EM menu in the front office & DCAC
2) Check for the availability EM SWP for all models and coverage of jobs mentioned in the menu
3) Cross-check of the EM SOP with the owner’s manual for all models/service types',
    '1) The EM SOPs must be located at the EM Stalls.
2) Key information like torque values of different models. Engine oil quantity, etc. must be displayed in the EM bay (charts / printed copy can be kept in inspector desk)',
    '1) EM SOP Model wise and Serivce interval wise (Dealer Specific)
2) EM Menu (Dealer Specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ036',
    'v1-DQ036-002',
    'Operation [Service]',
    'Workshop',
    'Does dealer has updated EM Menu and SWP as per market requirement recommended by Distributor guidelines?',
    'Operation [Service]',
    'Workshop',
    'EM SWP are available for all applicable models [including 40K service ] shown in menu',
    'Does dealer has updated EM Menu and SWP as per market requirement recommended by Distributor guidelines?',
    'Indirect',
    '3S',
    'EM SWP are available for all applicable models [including 40K service ] shown in menu',
    '*EM work procedures are designed for three man operation keeping in mind the minimum walking/waiting etc. of the technicians. Only when these procedures are defined correctly & followed, can the shorter lead times be achieved.

*In order to carry out a safe, high quality service & repair, it is essential to follow the TMC recommendations during vehicle servicing.',
    '1) Check for existence & usage of  EM menu in the front office & DCAC
2) Check for the availability EM SWP for all models and coverage of jobs mentioned in the menu
3) Cross-check of the EM SOP with the owner’s manual for all models/service types',
    '1) The EM SOPs must be located at the EM Stalls.
2) Key information like torque values of different models. Engine oil quantity, etc. must be displayed in the EM bay (charts / printed copy can be kept in inspector desk)',
    '1) EM SOP Model wise and Serivce interval wise (Dealer Specific)
2) EM Menu (Dealer Specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ036',
    'v1-DQ036-003',
    'Operation [Service]',
    'Workshop',
    'Does dealer has updated EM Menu and SWP as per market requirement recommended by Distributor guidelines?',
    'Operation [Service]',
    'Workshop',
    'All maintenance items outlined by owners manual are covered in SWP [Safety check points, Brake fluid, Lubricants, Run, Turn, Stop items]',
    'Does dealer has updated EM Menu and SWP as per market requirement recommended by Distributor guidelines?',
    'Indirect',
    '3S',
    'All maintenance items outlined by owners manual are covered in SWP [Safety check points, Brake fluid, Lubricants, Run, Turn, Stop items]',
    '*EM work procedures are designed for three man operation keeping in mind the minimum walking/waiting etc. of the technicians. Only when these procedures are defined correctly & followed, can the shorter lead times be achieved.

*In order to carry out a safe, high quality service & repair, it is essential to follow the TMC recommendations during vehicle servicing.',
    '1) Check for existence & usage of  EM menu in the front office & DCAC
2) Check for the availability EM SWP for all models and coverage of jobs mentioned in the menu
3) Cross-check of the EM SOP with the owner’s manual for all models/service types',
    '1) The EM SOPs must be located at the EM Stalls.
2) Key information like torque values of different models. Engine oil quantity, etc. must be displayed in the EM bay (charts / printed copy can be kept in inspector desk)',
    '1) EM SOP Model wise and Serivce interval wise (Dealer Specific)
2) EM Menu (Dealer Specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ037',
    'v1-DQ037-001',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensures EM SOP implementation and the following are complied as per distributor guidelines?',
    'Operation [Service]',
    'Workshop',
    'Express Maintenance is carried out according to the EM work procedures',
    'Does dealer ensures EM SOP implementation and the following are complied as per distributor guidelines?',
    'Direct',
    '3S',
    'Express Maintenance is carried out according to the EM work procedures',
    '*In order to carry out a safe, high quality service & repair, it is essential to follow the TMC recommendations during vehicle servicing. 

*All Safety items must be checked and confirmed by EM inspector (pro technician) & must fix if any defect is found.

*Usage of recommended material (Ex: high temperature grease) not only ensure the long life to the parts/vehicle but also the safety.

*To ensure the safe working environment and safety of the technicians',
    '1) Cross-check of the EM SOP with the owner’s manual & observe actual EM work of EM-Heavy [all 40K Service]
2) Check whether all recommended tools and Material are used during the EM Operations
3) Check that technician does not perform any dangerous operations like “running”, “any work on the vehicle while car lift is operating”, “when safety of staff is not checked by communicating [calling out]: before operating the car lift, starting the engine or moving the vehicle” and “not cleaning floor immediately after lubricants are spilled”. 
4) Check for the confirmation of the following safety check points
- Torquing of brake caliper bolt, engine oil drain nut plug, differential oil drain nut, wheel nut)
- Brake fluid bleeding as per the procedure using EM trolley vacuum system in EM bay
- Fluid quality & quantity  inspection - Brake fluid in reservoir, engine oil, Long life coolant, power steering fluid
- Brake pads & liner thickness / condition, brake disc / drum condition as per PM schedule (Use of measurement tools like Vernier caliper, dial gauge).
- Application of high temperature grease in the brake shoe contact points (8 point greasing)',
    'Check the usage of following tools
1) Dial gauge & Vernier caliper to inspect brake disc and pads/liner
2) Application of High temperature grease for rear brake as per repair manual  (contact point)
3) Usage of depth gauge to check tire threads
4) Torquing & marking (as per the standards) brake caliper bolt, engine oil & differential oil drain nuts, wheel nuts.',
    '1) EM SOP Model wise and Serivce Interval wise (Dealer Specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ037',
    'v1-DQ037-002',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensures EM SOP implementation and the following are complied as per distributor guidelines?',
    'Operation [Service]',
    'Workshop',
    'All maintenance items are carried out according to TKM instructions [Safety check points, Brake pad, Brake disc, Brake fluid, Lubricants, Run, Turn, Stop items]',
    'Does dealer ensures EM SOP implementation and the following are complied as per distributor guidelines?',
    'Direct',
    '3S',
    'All maintenance items are carried out according to TKM instructions [Safety check points, Brake pad, Brake disc, Brake fluid, Lubricants, Run, Turn, Stop items]',
    '*In order to carry out a safe, high quality service & repair, it is essential to follow the TMC recommendations during vehicle servicing. 

*All Safety items must be checked and confirmed by EM inspector (pro technician) & must fix if any defect is found.

*Usage of recommended material (Ex: high temperature grease) not only ensure the long life to the parts/vehicle but also the safety.

*To ensure the safe working environment and safety of the technicians',
    '1) Cross-check of the EM SOP with the owner’s manual & observe actual EM work of EM-Heavy [all 40K Service]
2) Check whether all recommended tools and Material are used during the EM Operations
3) Check that technician does not perform any dangerous operations like “running”, “any work on the vehicle while car lift is operating”, “when safety of staff is not checked by communicating [calling out]: before operating the car lift, starting the engine or moving the vehicle” and “not cleaning floor immediately after lubricants are spilled”. 
4) Check for the confirmation of the following safety check points
- Torquing of brake caliper bolt, engine oil drain nut plug, differential oil drain nut, wheel nut)
- Brake fluid bleeding as per the procedure using EM trolley vacuum system in EM bay
- Fluid quality & quantity  inspection - Brake fluid in reservoir, engine oil, Long life coolant, power steering fluid
- Brake pads & liner thickness / condition, brake disc / drum condition as per PM schedule (Use of measurement tools like Vernier caliper, dial gauge).
- Application of high temperature grease in the brake shoe contact points (8 point greasing)',
    'Check the usage of following tools
1) Dial gauge & Vernier caliper to inspect brake disc and pads/liner
2) Application of High temperature grease for rear brake as per repair manual  (contact point)
3) Usage of depth gauge to check tire threads
4) Torquing & marking (as per the standards) brake caliper bolt, engine oil & differential oil drain nuts, wheel nuts.',
    '1) EM SOP Model wise and Serivce Interval wise (Dealer Specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ037',
    'v1-DQ037-003',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensures EM SOP implementation and the following are complied as per distributor guidelines?',
    'Operation [Service]',
    'Workshop',
    'Following mandatory tools need to be used: Dial gauge, scale, torque wrenches, and battery tester / hydrometer]',
    'Does dealer ensures EM SOP implementation and the following are complied as per distributor guidelines?',
    'Direct',
    '3S',
    'Following mandatory tools need to be used: Dial gauge, scale, torque wrenches, and battery tester / hydrometer]',
    '*In order to carry out a safe, high quality service & repair, it is essential to follow the TMC recommendations during vehicle servicing. 

*All Safety items must be checked and confirmed by EM inspector (pro technician) & must fix if any defect is found.

*Usage of recommended material (Ex: high temperature grease) not only ensure the long life to the parts/vehicle but also the safety.

*To ensure the safe working environment and safety of the technicians',
    '1) Cross-check of the EM SOP with the owner’s manual & observe actual EM work of EM-Heavy [all 40K Service]
2) Check whether all recommended tools and Material are used during the EM Operations
3) Check that technician does not perform any dangerous operations like “running”, “any work on the vehicle while car lift is operating”, “when safety of staff is not checked by communicating [calling out]: before operating the car lift, starting the engine or moving the vehicle” and “not cleaning floor immediately after lubricants are spilled”. 
4) Check for the confirmation of the following safety check points
- Torquing of brake caliper bolt, engine oil drain nut plug, differential oil drain nut, wheel nut)
- Brake fluid bleeding as per the procedure using EM trolley vacuum system in EM bay
- Fluid quality & quantity  inspection - Brake fluid in reservoir, engine oil, Long life coolant, power steering fluid
- Brake pads & liner thickness / condition, brake disc / drum condition as per PM schedule (Use of measurement tools like Vernier caliper, dial gauge).
- Application of high temperature grease in the brake shoe contact points (8 point greasing)',
    'Check the usage of following tools
1) Dial gauge & Vernier caliper to inspect brake disc and pads/liner
2) Application of High temperature grease for rear brake as per repair manual  (contact point)
3) Usage of depth gauge to check tire threads
4) Torquing & marking (as per the standards) brake caliper bolt, engine oil & differential oil drain nuts, wheel nuts.',
    '1) EM SOP Model wise and Serivce Interval wise (Dealer Specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ037',
    'v1-DQ037-004',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensures EM SOP implementation and the following are complied as per distributor guidelines?',
    'Operation [Service]',
    'Workshop',
    'All recommended Material must be used during EM service [Engine Oil , Transmission Oil, Differential Oil, Brake Fluid and other lubricants, High Temperature Grease, Service Parts]',
    'Does dealer ensures EM SOP implementation and the following are complied as per distributor guidelines?',
    'Direct',
    '3S',
    'All recommended Material must be used during EM service [Engine Oil , Transmission Oil, Differential Oil, Brake Fluid and other lubricants, High Temperature Grease, Service Parts]',
    '*In order to carry out a safe, high quality service & repair, it is essential to follow the TMC recommendations during vehicle servicing. 

*All Safety items must be checked and confirmed by EM inspector (pro technician) & must fix if any defect is found.

*Usage of recommended material (Ex: high temperature grease) not only ensure the long life to the parts/vehicle but also the safety.

*To ensure the safe working environment and safety of the technicians',
    '1) Cross-check of the EM SOP with the owner’s manual & observe actual EM work of EM-Heavy [all 40K Service]
2) Check whether all recommended tools and Material are used during the EM Operations
3) Check that technician does not perform any dangerous operations like “running”, “any work on the vehicle while car lift is operating”, “when safety of staff is not checked by communicating [calling out]: before operating the car lift, starting the engine or moving the vehicle” and “not cleaning floor immediately after lubricants are spilled”. 
4) Check for the confirmation of the following safety check points
- Torquing of brake caliper bolt, engine oil drain nut plug, differential oil drain nut, wheel nut)
- Brake fluid bleeding as per the procedure using EM trolley vacuum system in EM bay
- Fluid quality & quantity  inspection - Brake fluid in reservoir, engine oil, Long life coolant, power steering fluid
- Brake pads & liner thickness / condition, brake disc / drum condition as per PM schedule (Use of measurement tools like Vernier caliper, dial gauge).
- Application of high temperature grease in the brake shoe contact points (8 point greasing)',
    'Check the usage of following tools
1) Dial gauge & Vernier caliper to inspect brake disc and pads/liner
2) Application of High temperature grease for rear brake as per repair manual  (contact point)
3) Usage of depth gauge to check tire threads
4) Torquing & marking (as per the standards) brake caliper bolt, engine oil & differential oil drain nuts, wheel nuts.',
    '1) EM SOP Model wise and Serivce Interval wise (Dealer Specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ037',
    'v1-DQ037-005',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensures EM SOP implementation and the following are complied as per distributor guidelines?',
    'Operation [Service]',
    'Workshop',
    'Express Maintenance is carried out safely',
    'Does dealer ensures EM SOP implementation and the following are complied as per distributor guidelines?',
    'Direct',
    '3S',
    'Express Maintenance is carried out safely',
    '*In order to carry out a safe, high quality service & repair, it is essential to follow the TMC recommendations during vehicle servicing. 

*All Safety items must be checked and confirmed by EM inspector (pro technician) & must fix if any defect is found.

*Usage of recommended material (Ex: high temperature grease) not only ensure the long life to the parts/vehicle but also the safety.

*To ensure the safe working environment and safety of the technicians',
    '1) Cross-check of the EM SOP with the owner’s manual & observe actual EM work of EM-Heavy [all 40K Service]
2) Check whether all recommended tools and Material are used during the EM Operations
3) Check that technician does not perform any dangerous operations like “running”, “any work on the vehicle while car lift is operating”, “when safety of staff is not checked by communicating [calling out]: before operating the car lift, starting the engine or moving the vehicle” and “not cleaning floor immediately after lubricants are spilled”. 
4) Check for the confirmation of the following safety check points
- Torquing of brake caliper bolt, engine oil drain nut plug, differential oil drain nut, wheel nut)
- Brake fluid bleeding as per the procedure using EM trolley vacuum system in EM bay
- Fluid quality & quantity  inspection - Brake fluid in reservoir, engine oil, Long life coolant, power steering fluid
- Brake pads & liner thickness / condition, brake disc / drum condition as per PM schedule (Use of measurement tools like Vernier caliper, dial gauge).
- Application of high temperature grease in the brake shoe contact points (8 point greasing)',
    'Check the usage of following tools
1) Dial gauge & Vernier caliper to inspect brake disc and pads/liner
2) Application of High temperature grease for rear brake as per repair manual  (contact point)
3) Usage of depth gauge to check tire threads
4) Torquing & marking (as per the standards) brake caliper bolt, engine oil & differential oil drain nuts, wheel nuts.',
    '1) EM SOP Model wise and Serivce Interval wise (Dealer Specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ038',
    'v1-DQ038-001',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Operation [Service]',
    'Workshop',
    'Sent 1st Notice to all affected Guests through Register post/Email',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Indirect',
    '3S',
    'Sent 1st Notice to all affected Guests through Register post/Email',
    '* Ensure the Mandatory Recall Policy

* Ensure that all the Vehicles Affected in the Campaign is informed to their respective Guests

* Visualize the  completion of Campaign',
    'Check Mandatory recall Policy (All Guest Notification and record Keeping)
1) Check Records of affected Guests V/s Notices and Mail sent - 2 Samples
2) Check Record maintenance of Acknowledgement/POD receipt - 2 Samples
3) Check KPI Monitoring for the Dealer Campaign Information to Guest (Communication to Guests)
4) Check KPI Monitoring for the Target Completion date & Percentage (Activity Completion status)',
    '1) Sample check (2 No''s Minimum) in CTDMS along with  Email, Registered post receipt (Online/Offline), POD status, Acknowledgement, Affected VIN No. list
2) Documents related to Campaign details & Percentage of Completion with Target dates
3) Documents on Actions taken for completing the campaign',
    '1) Recall Campaign SOP or Policy',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ038',
    'v1-DQ038-002',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Operation [Service]',
    'Workshop',
    'Record 1st Notice document, Acknowledgement / status',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Indirect',
    '3S',
    'Record 1st Notice document, Acknowledgement / status',
    '* Ensure the Mandatory Recall Policy

* Ensure that all the Vehicles Affected in the Campaign is informed to their respective Guests

* Visualize the  completion of Campaign',
    'Check Mandatory recall Policy (All Guest Notification and record Keeping)
1) Check Records of affected Guests V/s Notices and Mail sent - 2 Samples
2) Check Record maintenance of Acknowledgement/POD receipt - 2 Samples
3) Check KPI Monitoring for the Dealer Campaign Information to Guest (Communication to Guests)
4) Check KPI Monitoring for the Target Completion date & Percentage (Activity Completion status)',
    '1) Sample check (2 No''s Minimum) in CTDMS along with  Email, Registered post receipt (Online/Offline), POD status, Acknowledgement, Affected VIN No. list
2) Documents related to Campaign details & Percentage of Completion with Target dates
3) Documents on Actions taken for completing the campaign',
    '1) Recall Campaign SOP or Policy',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ038',
    'v1-DQ038-003',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Operation [Service]',
    'Workshop',
    'Sent 2nd Notice to all affected Guests through Register post/Email (After 90 days',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Indirect',
    '3S',
    'Sent 2nd Notice to all affected Guests through Register post/Email (After 90 days',
    '* Ensure the Mandatory Recall Policy

* Ensure that all the Vehicles Affected in the Campaign is informed to their respective Guests

* Visualize the  completion of Campaign',
    'Check Mandatory recall Policy (All Guest Notification and record Keeping)
1) Check Records of affected Guests V/s Notices and Mail sent - 2 Samples
2) Check Record maintenance of Acknowledgement/POD receipt - 2 Samples
3) Check KPI Monitoring for the Dealer Campaign Information to Guest (Communication to Guests)
4) Check KPI Monitoring for the Target Completion date & Percentage (Activity Completion status)',
    '1) Sample check (2 No''s Minimum) in CTDMS along with  Email, Registered post receipt (Online/Offline), POD status, Acknowledgement, Affected VIN No. list
2) Documents related to Campaign details & Percentage of Completion with Target dates
3) Documents on Actions taken for completing the campaign',
    '1) Recall Campaign SOP or Policy',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ038',
    'v1-DQ038-004',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Operation [Service]',
    'Workshop',
    'Record 2nd Notice document, Acknowledgement/Dispatch status',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Indirect',
    '3S',
    'Record 2nd Notice document, Acknowledgement/Dispatch status',
    '* Ensure the Mandatory Recall Policy

* Ensure that all the Vehicles Affected in the Campaign is informed to their respective Guests

* Visualize the  completion of Campaign',
    'Check Mandatory recall Policy (All Guest Notification and record Keeping)
1) Check Records of affected Guests V/s Notices and Mail sent - 2 Samples
2) Check Record maintenance of Acknowledgement/POD receipt - 2 Samples
3) Check KPI Monitoring for the Dealer Campaign Information to Guest (Communication to Guests)
4) Check KPI Monitoring for the Target Completion date & Percentage (Activity Completion status)',
    '1) Sample check (2 No''s Minimum) in CTDMS along with  Email, Registered post receipt (Online/Offline), POD status, Acknowledgement, Affected VIN No. list
2) Documents related to Campaign details & Percentage of Completion with Target dates
3) Documents on Actions taken for completing the campaign',
    '1) Recall Campaign SOP or Policy',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ038',
    'v1-DQ038-005',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Operation [Service]',
    'Workshop',
    'Send 3rd & 4th Notice to non-traceable VIN/Dispatched Guests',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Indirect',
    '3S',
    'Send 3rd & 4th Notice to non-traceable VIN/Dispatched Guests',
    '* Ensure the Mandatory Recall Policy

* Ensure that all the Vehicles Affected in the Campaign is informed to their respective Guests

* Visualize the  completion of Campaign',
    'Check Mandatory recall Policy (All Guest Notification and record Keeping)
1) Check Records of affected Guests V/s Notices and Mail sent - 2 Samples
2) Check Record maintenance of Acknowledgement/POD receipt - 2 Samples
3) Check KPI Monitoring for the Dealer Campaign Information to Guest (Communication to Guests)
4) Check KPI Monitoring for the Target Completion date & Percentage (Activity Completion status)',
    '1) Sample check (2 No''s Minimum) in CTDMS along with  Email, Registered post receipt (Online/Offline), POD status, Acknowledgement, Affected VIN No. list
2) Documents related to Campaign details & Percentage of Completion with Target dates
3) Documents on Actions taken for completing the campaign',
    '1) Recall Campaign SOP or Policy',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ038',
    'v1-DQ038-006',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Operation [Service]',
    'Workshop',
    'Record (Store 3rd & 4th Notice document, Acknowledgement/POD Status)',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Indirect',
    '3S',
    'Record (Store 3rd & 4th Notice document, Acknowledgement/POD Status)',
    '* Ensure the Mandatory Recall Policy

* Ensure that all the Vehicles Affected in the Campaign is informed to their respective Guests

* Visualize the  completion of Campaign',
    'Check Mandatory recall Policy (All Guest Notification and record Keeping)
1) Check Records of affected Guests V/s Notices and Mail sent - 2 Samples
2) Check Record maintenance of Acknowledgement/POD receipt - 2 Samples
3) Check KPI Monitoring for the Dealer Campaign Information to Guest (Communication to Guests)
4) Check KPI Monitoring for the Target Completion date & Percentage (Activity Completion status)',
    '1) Sample check (2 No''s Minimum) in CTDMS along with  Email, Registered post receipt (Online/Offline), POD status, Acknowledgement, Affected VIN No. list
2) Documents related to Campaign details & Percentage of Completion with Target dates
3) Documents on Actions taken for completing the campaign',
    '1) Recall Campaign SOP or Policy',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ038',
    'v1-DQ038-007',
    'Operation [Service]',
    'Workshop',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Operation [Service]',
    'Workshop',
    'Reminder calls to Guests',
    'Does dealer ensure  the following for 100 % of Technical campaigns / Mandatory Recalls?',
    'Indirect',
    '3S',
    'Reminder calls to Guests',
    '* Ensure the Mandatory Recall Policy

* Ensure that all the Vehicles Affected in the Campaign is informed to their respective Guests

* Visualize the  completion of Campaign',
    'Check Mandatory recall Policy (All Guest Notification and record Keeping)
1) Check Records of affected Guests V/s Notices and Mail sent - 2 Samples
2) Check Record maintenance of Acknowledgement/POD receipt - 2 Samples
3) Check KPI Monitoring for the Dealer Campaign Information to Guest (Communication to Guests)
4) Check KPI Monitoring for the Target Completion date & Percentage (Activity Completion status)',
    '1) Sample check (2 No''s Minimum) in CTDMS along with  Email, Registered post receipt (Online/Offline), POD status, Acknowledgement, Affected VIN No. list
2) Documents related to Campaign details & Percentage of Completion with Target dates
3) Documents on Actions taken for completing the campaign',
    '1) Recall Campaign SOP or Policy',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ039',
    'v1-DQ039-001',
    'Operation [Service]',
    'Workshop',
    'Does dealer staff performs following repair & warranty process?',
    'Operation [Service]',
    'Workshop',
    'Follow standard warranty operations as per TKM guidelines',
    'Does dealer staff performs following repair & warranty process?',
    'Indirect',
    '3S',
    'Follow standard warranty operations as per TKM guidelines',
    '* Effective Warranty operations

* Minimize part recovery Leadtime

* Ensure proper scrapping of warranty replaced parts',
    '1) Check warranty parts are stored as per period with tags (N, N-1, N-2 month slot) & duly filled
2) Dealer Stores the Dealer custody parts separately on distributor instruction
3) Periodically warranty parts scrapping is done as per TKM guideline & 4S is maintained in store
4) 100% Hybrid Battery replaced under warranty are sent back to TKM as per the SOP. Non Warranty replaced Hybrid Battery despite guiding with safety risk in case taken away by the Guest formal undertaking is obtained from Guest on prescribed format.
5) Check visualization of repair support route document indicating condition & escalation timeline.
6) Interview with CGT, Chief Technician and Technician to check their understanding in the repair support route.',
    '1) There should be a written procedure for handling warranty parts.
2) Dates for discard should be easily seen; once that date is reached ,the item should be discarded.
3) A parts claim tag should be attached to the part. The failed area should be clearly identified
4) Record of Hybrid Batteries replaced and its disposal - dispatch to TKM or undertaking from Guest
5) Check availability of repair support documents.',
    '1) Warranty Procedure SOP
2) Hybrid Battery Handling SOP',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ039',
    'v1-DQ039-002',
    'Operation [Service]',
    'Workshop',
    'Does dealer staff performs following repair & warranty process?',
    'Operation [Service]',
    'Workshop',
    'Dealer sends the Hybrid Battery removed from the vehicle properly to TKM',
    'Does dealer staff performs following repair & warranty process?',
    'Indirect',
    '3S',
    'Dealer sends the Hybrid Battery removed from the vehicle properly to TKM',
    '* Effective Warranty operations

* Minimize part recovery Leadtime

* Ensure proper scrapping of warranty replaced parts',
    '1) Check warranty parts are stored as per period with tags (N, N-1, N-2 month slot) & duly filled
2) Dealer Stores the Dealer custody parts separately on distributor instruction
3) Periodically warranty parts scrapping is done as per TKM guideline & 4S is maintained in store
4) 100% Hybrid Battery replaced under warranty are sent back to TKM as per the SOP. Non Warranty replaced Hybrid Battery despite guiding with safety risk in case taken away by the Guest formal undertaking is obtained from Guest on prescribed format.
5) Check visualization of repair support route document indicating condition & escalation timeline.
6) Interview with CGT, Chief Technician and Technician to check their understanding in the repair support route.',
    '1) There should be a written procedure for handling warranty parts.
2) Dates for discard should be easily seen; once that date is reached ,the item should be discarded.
3) A parts claim tag should be attached to the part. The failed area should be clearly identified
4) Record of Hybrid Batteries replaced and its disposal - dispatch to TKM or undertaking from Guest
5) Check availability of repair support documents.',
    '1) Warranty Procedure SOP
2) Hybrid Battery Handling SOP',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ039',
    'v1-DQ039-003',
    'Operation [Service]',
    'Workshop',
    'Does dealer staff performs following repair & warranty process?',
    'Operation [Service]',
    'Workshop',
    'Repair support routing for escalation of difficult to diagnose / repair (by technician / dealer to skilled personnel is available & followed)',
    'Does dealer staff performs following repair & warranty process?',
    'Indirect',
    '3S',
    'Repair support routing for escalation of difficult to diagnose / repair (by technician / dealer to skilled personnel is available & followed)',
    '* Effective Warranty operations

* Minimize part recovery Leadtime

* Ensure proper scrapping of warranty replaced parts',
    '1) Check warranty parts are stored as per period with tags (N, N-1, N-2 month slot) & duly filled
2) Dealer Stores the Dealer custody parts separately on distributor instruction
3) Periodically warranty parts scrapping is done as per TKM guideline & 4S is maintained in store
4) 100% Hybrid Battery replaced under warranty are sent back to TKM as per the SOP. Non Warranty replaced Hybrid Battery despite guiding with safety risk in case taken away by the Guest formal undertaking is obtained from Guest on prescribed format.
5) Check visualization of repair support route document indicating condition & escalation timeline.
6) Interview with CGT, Chief Technician and Technician to check their understanding in the repair support route.',
    '1) There should be a written procedure for handling warranty parts.
2) Dates for discard should be easily seen; once that date is reached ,the item should be discarded.
3) A parts claim tag should be attached to the part. The failed area should be clearly identified
4) Record of Hybrid Batteries replaced and its disposal - dispatch to TKM or undertaking from Guest
5) Check availability of repair support documents.',
    '1) Warranty Procedure SOP
2) Hybrid Battery Handling SOP',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ040',
    'v1-DQ040-001',
    'Facility',
    'Reception / Back office / Workshop',
    'Does the dealer have following facilities for staff?',
    'Facility',
    'Reception / Back office / Workshop',
    'Facilities for staff that are regularly cleaned and maintained',
    'Does the dealer have following facilities for staff?',
    'Indirect',
    '3S',
    'Facilities for staff that are regularly cleaned and maintained',
    '*A clean and orderly staff facility creates a feeling of comfort & hygiene for dealer staff and achieves employee satisfaction.

*Ensure continuous effort for Employee satisfaction and monitor the results

*Ensure physical well-being of technician

*Encourages staff retention',
    '1) Check the Availability, Condition & Maintenance of all staff facilities.
2) Check for these staff facilities - Uniform, name badges for Guest facing staff, Washrooms & shower facility, lounge/restrooms, place for lunch, parking.
3) Check the Dealer does the  Annual Health check up for all the technician (at least GS & BP tech)
4) Check dealer has a mechanism to check the employee satisfaction & employee engagement
5) Check turnover rate (Attrition rate) of GEM (Service) ''s and technicians',
    'The following items need to be checked:
1) Well maintained staff facility: Changing room, toilets, employee parking and specific area for the staff to rest and eat
2) Staff Uniform & Name Badges
3) Record of Annual Health Report 
4) Employee Satisfaction Survey conducted on regular basis and action thereon
5) Evidence of Employee Satisfaction Activities (Photos, etc.)
6) Turnover rate monitoring (KPI) of GEM-Service''s and Technicians',
    '1) DIVA guidelines (Staff facilities)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ040',
    'v1-DQ040-002',
    'Facility',
    'Reception / Back office / Workshop',
    'Does the dealer have following facilities for staff?',
    'Facility',
    'Reception / Back office / Workshop',
    'Mechanism to Improve Employee Satisfaction based on ESI or Employee’s Voice',
    'Does the dealer have following facilities for staff?',
    'Indirect',
    '3S',
    'Mechanism to Improve Employee Satisfaction based on ESI or Employee’s Voice',
    '*A clean and orderly staff facility creates a feeling of comfort & hygiene for dealer staff and achieves employee satisfaction.

*Ensure continuous effort for Employee satisfaction and monitor the results

*Ensure physical well-being of technician

*Encourages staff retention',
    '1) Check the Availability, Condition & Maintenance of all staff facilities.
2) Check for these staff facilities - Uniform, name badges for Guest facing staff, Washrooms & shower facility, lounge/restrooms, place for lunch, parking.
3) Check the Dealer does the  Annual Health check up for all the technician (at least GS & BP tech)
4) Check dealer has a mechanism to check the employee satisfaction & employee engagement
5) Check turnover rate (Attrition rate) of GEM (Service) ''s and technicians',
    'The following items need to be checked:
1) Well maintained staff facility: Changing room, toilets, employee parking and specific area for the staff to rest and eat
2) Staff Uniform & Name Badges
3) Record of Annual Health Report 
4) Employee Satisfaction Survey conducted on regular basis and action thereon
5) Evidence of Employee Satisfaction Activities (Photos, etc.)
6) Turnover rate monitoring (KPI) of GEM-Service''s and Technicians',
    '1) DIVA guidelines (Staff facilities)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ040',
    'v1-DQ040-003',
    'Facility',
    'Reception / Back office / Workshop',
    'Does the dealer have following facilities for staff?',
    'Facility',
    'Reception / Back office / Workshop',
    'Annual Health Check-Up for In-house Technicians (minimum criterion is technicians, however, it is good practice to include all employees',
    'Does the dealer have following facilities for staff?',
    'Indirect',
    '3S',
    'Annual Health Check-Up for In-house Technicians (minimum criterion is technicians, however, it is good practice to include all employees',
    '*A clean and orderly staff facility creates a feeling of comfort & hygiene for dealer staff and achieves employee satisfaction.

*Ensure continuous effort for Employee satisfaction and monitor the results

*Ensure physical well-being of technician

*Encourages staff retention',
    '1) Check the Availability, Condition & Maintenance of all staff facilities.
2) Check for these staff facilities - Uniform, name badges for Guest facing staff, Washrooms & shower facility, lounge/restrooms, place for lunch, parking.
3) Check the Dealer does the  Annual Health check up for all the technician (at least GS & BP tech)
4) Check dealer has a mechanism to check the employee satisfaction & employee engagement
5) Check turnover rate (Attrition rate) of GEM (Service) ''s and technicians',
    'The following items need to be checked:
1) Well maintained staff facility: Changing room, toilets, employee parking and specific area for the staff to rest and eat
2) Staff Uniform & Name Badges
3) Record of Annual Health Report 
4) Employee Satisfaction Survey conducted on regular basis and action thereon
5) Evidence of Employee Satisfaction Activities (Photos, etc.)
6) Turnover rate monitoring (KPI) of GEM-Service''s and Technicians',
    '1) DIVA guidelines (Staff facilities)',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ041',
    'v1-DQ041-001',
    'Operation [Service]',
    'Parts Warehouse',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Operation [Service]',
    'Parts Warehouse',
    '7 storage techniques, 4S & visibility (light intensity',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Indirect',
    '3S',
    '7 storage techniques, 4S & visibility (light intensity',
    '* 7 storage techniques create a parts working area that maintains below points 

* Parts quality, Utilize Safe Handling Procedures.

* Ensures effective space utilization and efficient operation.',
    '1) Check if 7 Step storage techniques are displayed and applied in parts warehouse
2) Light intensity to should be > 300 lux (measure at aisle between the racks)
3) Check if the irregularities are visualized in the parts storage (Excess part stored outside location are identified, empty bins / locations visualized)
4) Parts pre-pull rack available & pre pull process is performed (Check if the parts are pre pulled for planned vehicles)
5) Check the SOP and confirm with the actual operations of Special Order & Back order (B/O) Parts ordering and handling
6) Unused special order parts & dead stock is stored in designated location and managed according to the dealer established rules (SOP).
7) Check if Parts warehouse has established channel to capture special order parts requirement & communicate the status to Service GEM or TL / DCAC & front office, through written/digital mode(Mail, Shared Excel)
8) Check the Visualization of B/O ETA and how the information is shared with Guest through DCAC or GEM-Service
9) Check if KPIs are monitored, visualized & reviewed periodically (ROFR, Stock month, Dead stock)
10) Check the availability of fire extinguishers & smoke detectors in the working condition. Confirm daily audit is done in the warehouse & fire extinguishers are replaced as per schedule
11) Check if the hazardous materials like oil, battery are stored separately in a safe location',
    '7 Storage Technique display & Parts Storage condition in the Warehouse
1) Similar parts grouped together
2) Long and thin parts stored vertically
3) Parts stored within easy reach
4) Heavy parts stored down low, or at waist level
5) There is a separate location for each part number
6) There is irregularity control by visual means
7) Parts stored according to moving class',
    '1) Parts Warehouse guideline (7 storage technique)
2) Parts Storage SOP
3) Dead stock handling policy (Dealer specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ041',
    'v1-DQ041-002',
    'Operation [Service]',
    'Parts Warehouse',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Operation [Service]',
    'Parts Warehouse',
    'Sufficient Light Intensity inside the parts warehouse (> 300 lux',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Indirect',
    '3S',
    'Sufficient Light Intensity inside the parts warehouse (> 300 lux',
    '* 7 storage techniques create a parts working area that maintains below points 

* Parts quality, Utilize Safe Handling Procedures.

* Ensures effective space utilization and efficient operation.',
    '1) Check if 7 Step storage techniques are displayed and applied in parts warehouse
2) Light intensity to should be > 300 lux (measure at aisle between the racks)
3) Check if the irregularities are visualized in the parts storage (Excess part stored outside location are identified, empty bins / locations visualized)
4) Parts pre-pull rack available & pre pull process is performed (Check if the parts are pre pulled for planned vehicles)
5) Check the SOP and confirm with the actual operations of Special Order & Back order (B/O) Parts ordering and handling
6) Unused special order parts & dead stock is stored in designated location and managed according to the dealer established rules (SOP).
7) Check if Parts warehouse has established channel to capture special order parts requirement & communicate the status to Service GEM or TL / DCAC & front office, through written/digital mode(Mail, Shared Excel)
8) Check the Visualization of B/O ETA and how the information is shared with Guest through DCAC or GEM-Service
9) Check if KPIs are monitored, visualized & reviewed periodically (ROFR, Stock month, Dead stock)
10) Check the availability of fire extinguishers & smoke detectors in the working condition. Confirm daily audit is done in the warehouse & fire extinguishers are replaced as per schedule
11) Check if the hazardous materials like oil, battery are stored separately in a safe location',
    '7 Storage Technique display & Parts Storage condition in the Warehouse
1) Similar parts grouped together
2) Long and thin parts stored vertically
3) Parts stored within easy reach
4) Heavy parts stored down low, or at waist level
5) There is a separate location for each part number
6) There is irregularity control by visual means
7) Parts stored according to moving class',
    '1) Parts Warehouse guideline (7 storage technique)
2) Parts Storage SOP
3) Dead stock handling policy (Dealer specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ041',
    'v1-DQ041-003',
    'Operation [Service]',
    'Parts Warehouse',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Operation [Service]',
    'Parts Warehouse',
    'Pre-pull of parts for planned service vehicles (Availability & usage of Pre-Pick Parts Rack',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Indirect',
    '3S',
    'Pre-pull of parts for planned service vehicles (Availability & usage of Pre-Pick Parts Rack',
    '* 7 storage techniques create a parts working area that maintains below points 

* Parts quality, Utilize Safe Handling Procedures.

* Ensures effective space utilization and efficient operation.',
    '1) Check if 7 Step storage techniques are displayed and applied in parts warehouse
2) Light intensity to should be > 300 lux (measure at aisle between the racks)
3) Check if the irregularities are visualized in the parts storage (Excess part stored outside location are identified, empty bins / locations visualized)
4) Parts pre-pull rack available & pre pull process is performed (Check if the parts are pre pulled for planned vehicles)
5) Check the SOP and confirm with the actual operations of Special Order & Back order (B/O) Parts ordering and handling
6) Unused special order parts & dead stock is stored in designated location and managed according to the dealer established rules (SOP).
7) Check if Parts warehouse has established channel to capture special order parts requirement & communicate the status to Service GEM or TL / DCAC & front office, through written/digital mode(Mail, Shared Excel)
8) Check the Visualization of B/O ETA and how the information is shared with Guest through DCAC or GEM-Service
9) Check if KPIs are monitored, visualized & reviewed periodically (ROFR, Stock month, Dead stock)
10) Check the availability of fire extinguishers & smoke detectors in the working condition. Confirm daily audit is done in the warehouse & fire extinguishers are replaced as per schedule
11) Check if the hazardous materials like oil, battery are stored separately in a safe location',
    '7 Storage Technique display & Parts Storage condition in the Warehouse
1) Similar parts grouped together
2) Long and thin parts stored vertically
3) Parts stored within easy reach
4) Heavy parts stored down low, or at waist level
5) There is a separate location for each part number
6) There is irregularity control by visual means
7) Parts stored according to moving class',
    '1) Parts Warehouse guideline (7 storage technique)
2) Parts Storage SOP
3) Dead stock handling policy (Dealer specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ041',
    'v1-DQ041-004',
    'Operation [Service]',
    'Parts Warehouse',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Operation [Service]',
    'Parts Warehouse',
    'Special order parts SOP & Tools are implemented to ensure guest convenience while maintaining lean stock',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Indirect',
    '3S',
    'Special order parts SOP & Tools are implemented to ensure guest convenience while maintaining lean stock',
    '* 7 storage techniques create a parts working area that maintains below points 

* Parts quality, Utilize Safe Handling Procedures.

* Ensures effective space utilization and efficient operation.',
    '1) Check if 7 Step storage techniques are displayed and applied in parts warehouse
2) Light intensity to should be > 300 lux (measure at aisle between the racks)
3) Check if the irregularities are visualized in the parts storage (Excess part stored outside location are identified, empty bins / locations visualized)
4) Parts pre-pull rack available & pre pull process is performed (Check if the parts are pre pulled for planned vehicles)
5) Check the SOP and confirm with the actual operations of Special Order & Back order (B/O) Parts ordering and handling
6) Unused special order parts & dead stock is stored in designated location and managed according to the dealer established rules (SOP).
7) Check if Parts warehouse has established channel to capture special order parts requirement & communicate the status to Service GEM or TL / DCAC & front office, through written/digital mode(Mail, Shared Excel)
8) Check the Visualization of B/O ETA and how the information is shared with Guest through DCAC or GEM-Service
9) Check if KPIs are monitored, visualized & reviewed periodically (ROFR, Stock month, Dead stock)
10) Check the availability of fire extinguishers & smoke detectors in the working condition. Confirm daily audit is done in the warehouse & fire extinguishers are replaced as per schedule
11) Check if the hazardous materials like oil, battery are stored separately in a safe location',
    '7 Storage Technique display & Parts Storage condition in the Warehouse
1) Similar parts grouped together
2) Long and thin parts stored vertically
3) Parts stored within easy reach
4) Heavy parts stored down low, or at waist level
5) There is a separate location for each part number
6) There is irregularity control by visual means
7) Parts stored according to moving class',
    '1) Parts Warehouse guideline (7 storage technique)
2) Parts Storage SOP
3) Dead stock handling policy (Dealer specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  );

INSERT INTO audit_checklist_master (
  checklist_code,
  version,
  section,
  area,
  chapter,
  classification,
  location_aspect,
  evaluation_question,
  evaluation_parameter,
  guest_experience_impact,
  facility_type,
  question,
  purpose,
  checking_method,
  additional_info,
  sop_reference,
  evidence_required,
  applicable_departments,
  status
) VALUES
(
    'DQ041',
    'v1-DQ041-005',
    'Operation [Service]',
    'Parts Warehouse',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Operation [Service]',
    'Parts Warehouse',
    'Unused or dead stock parts are properly managed as per the established rules (SOP',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Indirect',
    '3S',
    'Unused or dead stock parts are properly managed as per the established rules (SOP',
    '* 7 storage techniques create a parts working area that maintains below points 

* Parts quality, Utilize Safe Handling Procedures.

* Ensures effective space utilization and efficient operation.',
    '1) Check if 7 Step storage techniques are displayed and applied in parts warehouse
2) Light intensity to should be > 300 lux (measure at aisle between the racks)
3) Check if the irregularities are visualized in the parts storage (Excess part stored outside location are identified, empty bins / locations visualized)
4) Parts pre-pull rack available & pre pull process is performed (Check if the parts are pre pulled for planned vehicles)
5) Check the SOP and confirm with the actual operations of Special Order & Back order (B/O) Parts ordering and handling
6) Unused special order parts & dead stock is stored in designated location and managed according to the dealer established rules (SOP).
7) Check if Parts warehouse has established channel to capture special order parts requirement & communicate the status to Service GEM or TL / DCAC & front office, through written/digital mode(Mail, Shared Excel)
8) Check the Visualization of B/O ETA and how the information is shared with Guest through DCAC or GEM-Service
9) Check if KPIs are monitored, visualized & reviewed periodically (ROFR, Stock month, Dead stock)
10) Check the availability of fire extinguishers & smoke detectors in the working condition. Confirm daily audit is done in the warehouse & fire extinguishers are replaced as per schedule
11) Check if the hazardous materials like oil, battery are stored separately in a safe location',
    '7 Storage Technique display & Parts Storage condition in the Warehouse
1) Similar parts grouped together
2) Long and thin parts stored vertically
3) Parts stored within easy reach
4) Heavy parts stored down low, or at waist level
5) There is a separate location for each part number
6) There is irregularity control by visual means
7) Parts stored according to moving class',
    '1) Parts Warehouse guideline (7 storage technique)
2) Parts Storage SOP
3) Dead stock handling policy (Dealer specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ041',
    'v1-DQ041-006',
    'Operation [Service]',
    'Parts Warehouse',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Operation [Service]',
    'Parts Warehouse',
    'Parts stock review and performance monitoring',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Indirect',
    '3S',
    'Parts stock review and performance monitoring',
    '* 7 storage techniques create a parts working area that maintains below points 

* Parts quality, Utilize Safe Handling Procedures.

* Ensures effective space utilization and efficient operation.',
    '1) Check if 7 Step storage techniques are displayed and applied in parts warehouse
2) Light intensity to should be > 300 lux (measure at aisle between the racks)
3) Check if the irregularities are visualized in the parts storage (Excess part stored outside location are identified, empty bins / locations visualized)
4) Parts pre-pull rack available & pre pull process is performed (Check if the parts are pre pulled for planned vehicles)
5) Check the SOP and confirm with the actual operations of Special Order & Back order (B/O) Parts ordering and handling
6) Unused special order parts & dead stock is stored in designated location and managed according to the dealer established rules (SOP).
7) Check if Parts warehouse has established channel to capture special order parts requirement & communicate the status to Service GEM or TL / DCAC & front office, through written/digital mode(Mail, Shared Excel)
8) Check the Visualization of B/O ETA and how the information is shared with Guest through DCAC or GEM-Service
9) Check if KPIs are monitored, visualized & reviewed periodically (ROFR, Stock month, Dead stock)
10) Check the availability of fire extinguishers & smoke detectors in the working condition. Confirm daily audit is done in the warehouse & fire extinguishers are replaced as per schedule
11) Check if the hazardous materials like oil, battery are stored separately in a safe location',
    '7 Storage Technique display & Parts Storage condition in the Warehouse
1) Similar parts grouped together
2) Long and thin parts stored vertically
3) Parts stored within easy reach
4) Heavy parts stored down low, or at waist level
5) There is a separate location for each part number
6) There is irregularity control by visual means
7) Parts stored according to moving class',
    '1) Parts Warehouse guideline (7 storage technique)
2) Parts Storage SOP
3) Dead stock handling policy (Dealer specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ041',
    'v1-DQ041-007',
    'Operation [Service]',
    'Parts Warehouse',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Operation [Service]',
    'Parts Warehouse',
    'Safety is ensured in the parts warehouse (availability of fire extinguishers & smoke detectors in the working condition, safe storage of hazardous materials like oil, battery',
    'Does dealer ensures Parts Warehouse operations complies with the following?',
    'Indirect',
    '3S',
    'Safety is ensured in the parts warehouse (availability of fire extinguishers & smoke detectors in the working condition, safe storage of hazardous materials like oil, battery',
    '* 7 storage techniques create a parts working area that maintains below points 

* Parts quality, Utilize Safe Handling Procedures.

* Ensures effective space utilization and efficient operation.',
    '1) Check if 7 Step storage techniques are displayed and applied in parts warehouse
2) Light intensity to should be > 300 lux (measure at aisle between the racks)
3) Check if the irregularities are visualized in the parts storage (Excess part stored outside location are identified, empty bins / locations visualized)
4) Parts pre-pull rack available & pre pull process is performed (Check if the parts are pre pulled for planned vehicles)
5) Check the SOP and confirm with the actual operations of Special Order & Back order (B/O) Parts ordering and handling
6) Unused special order parts & dead stock is stored in designated location and managed according to the dealer established rules (SOP).
7) Check if Parts warehouse has established channel to capture special order parts requirement & communicate the status to Service GEM or TL / DCAC & front office, through written/digital mode(Mail, Shared Excel)
8) Check the Visualization of B/O ETA and how the information is shared with Guest through DCAC or GEM-Service
9) Check if KPIs are monitored, visualized & reviewed periodically (ROFR, Stock month, Dead stock)
10) Check the availability of fire extinguishers & smoke detectors in the working condition. Confirm daily audit is done in the warehouse & fire extinguishers are replaced as per schedule
11) Check if the hazardous materials like oil, battery are stored separately in a safe location',
    '7 Storage Technique display & Parts Storage condition in the Warehouse
1) Similar parts grouped together
2) Long and thin parts stored vertically
3) Parts stored within easy reach
4) Heavy parts stored down low, or at waist level
5) There is a separate location for each part number
6) There is irregularity control by visual means
7) Parts stored according to moving class',
    '1) Parts Warehouse guideline (7 storage technique)
2) Parts Storage SOP
3) Dead stock handling policy (Dealer specific)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ042',
    'v1-DQ042-001',
    'Facility',
    'Workshop',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Facility',
    'Workshop',
    'Tools & equipment condition and usage- Frame aligner, tracking gauge, safety wires.',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Indirect',
    '3S',
    'Tools & equipment condition and usage- Frame aligner, tracking gauge, safety wires.',
    '*To ensure repair quality by possessing and using the necessary tools & equipment

*To ensure welding repair quality',
    '1) Check for availability and usage condition of listed tools & equipment in body repair process 
- Frame aligner, Tracking gauge (Calibration), Safety wire, Air saw, MAG welder, Spot welder, Hemming tool, Straight edge, washer welder, single action / roloc sander
2) Check if hydraulic equipment work normally and there is no oil leakage.
3) Check If there is no excessive gap between the MAG Welder contact tip''s central hole and wire and no obvious spatter adhered inside the nozzle
4) Check for availability and usage condition of listed tools & equipment in paint repair process 
- Dual action sander, dust collection equipment, infrared dryer, Spray gun, paint mixing scale (calibrated), Oil-water separator(Air dryer unit).
5) Check If paint booth walls / floor are free from dust and no sagging & clogging of roof filter and exhaust filters.
6) Check for regular maintenance check sheet available (Daily / Weekly / Monthly / Annually) along with PIC & updated as per current date for all the quipments
7) Check all paint containers are closed properly and buffing pad 4S condition. 
8) Check whether Tools & Equipment are assigned dedicated location with clear demarcation.
9) Check the availability & usage of listed consumables in body & paint repair process
- Body sealant, undercoat, rust proofing, resin adhesive, Urethane surfacer, masking materials, paint strainer *Refer the T&E annexure for details',
    '1) Visually confirm the mentioned tools & equipment condition and usage.
2) Paint booth cleaning process charts display.
3) Visually confirm the availability of maintenance sheet attached with each equipment and the same is duly updated.
4) Records of previous maintenance log''s of all equipment in register or soft copy.
5) Periodic maintenance schedule  for equipment as per point no "f" in checking method',
    '1) BP Tools & Equipment Annexure and guidebook',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ042',
    'v1-DQ042-002',
    'Facility',
    'Workshop',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Facility',
    'Workshop',
    'Tools & equipment condition and usage for Panel Repair process - Air Saw, MAG Welder, Spot Welder, Hemming Tool, Straight edge, washer welders, Single action / roloc sander.',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Indirect',
    '3S',
    'Tools & equipment condition and usage for Panel Repair process - Air Saw, MAG Welder, Spot Welder, Hemming Tool, Straight edge, washer welders, Single action / roloc sander.',
    '*To ensure repair quality by possessing and using the necessary tools & equipment

*To ensure welding repair quality',
    '1) Check for availability and usage condition of listed tools & equipment in body repair process 
- Frame aligner, Tracking gauge (Calibration), Safety wire, Air saw, MAG welder, Spot welder, Hemming tool, Straight edge, washer welder, single action / roloc sander
2) Check if hydraulic equipment work normally and there is no oil leakage.
3) Check If there is no excessive gap between the MAG Welder contact tip''s central hole and wire and no obvious spatter adhered inside the nozzle
4) Check for availability and usage condition of listed tools & equipment in paint repair process 
- Dual action sander, dust collection equipment, infrared dryer, Spray gun, paint mixing scale (calibrated), Oil-water separator(Air dryer unit).
5) Check If paint booth walls / floor are free from dust and no sagging & clogging of roof filter and exhaust filters.
6) Check for regular maintenance check sheet available (Daily / Weekly / Monthly / Annually) along with PIC & updated as per current date for all the quipments
7) Check all paint containers are closed properly and buffing pad 4S condition. 
8) Check whether Tools & Equipment are assigned dedicated location with clear demarcation.
9) Check the availability & usage of listed consumables in body & paint repair process
- Body sealant, undercoat, rust proofing, resin adhesive, Urethane surfacer, masking materials, paint strainer *Refer the T&E annexure for details',
    '1) Visually confirm the mentioned tools & equipment condition and usage.
2) Paint booth cleaning process charts display.
3) Visually confirm the availability of maintenance sheet attached with each equipment and the same is duly updated.
4) Records of previous maintenance log''s of all equipment in register or soft copy.
5) Periodic maintenance schedule  for equipment as per point no "f" in checking method',
    '1) BP Tools & Equipment Annexure and guidebook',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ042',
    'v1-DQ042-003',
    'Facility',
    'Workshop',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Facility',
    'Workshop',
    'Welding machine working condition & Tip condition.',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Indirect',
    '3S',
    'Welding machine working condition & Tip condition.',
    '*To ensure repair quality by possessing and using the necessary tools & equipment

*To ensure welding repair quality',
    '1) Check for availability and usage condition of listed tools & equipment in body repair process 
- Frame aligner, Tracking gauge (Calibration), Safety wire, Air saw, MAG welder, Spot welder, Hemming tool, Straight edge, washer welder, single action / roloc sander
2) Check if hydraulic equipment work normally and there is no oil leakage.
3) Check If there is no excessive gap between the MAG Welder contact tip''s central hole and wire and no obvious spatter adhered inside the nozzle
4) Check for availability and usage condition of listed tools & equipment in paint repair process 
- Dual action sander, dust collection equipment, infrared dryer, Spray gun, paint mixing scale (calibrated), Oil-water separator(Air dryer unit).
5) Check If paint booth walls / floor are free from dust and no sagging & clogging of roof filter and exhaust filters.
6) Check for regular maintenance check sheet available (Daily / Weekly / Monthly / Annually) along with PIC & updated as per current date for all the quipments
7) Check all paint containers are closed properly and buffing pad 4S condition. 
8) Check whether Tools & Equipment are assigned dedicated location with clear demarcation.
9) Check the availability & usage of listed consumables in body & paint repair process
- Body sealant, undercoat, rust proofing, resin adhesive, Urethane surfacer, masking materials, paint strainer *Refer the T&E annexure for details',
    '1) Visually confirm the mentioned tools & equipment condition and usage.
2) Paint booth cleaning process charts display.
3) Visually confirm the availability of maintenance sheet attached with each equipment and the same is duly updated.
4) Records of previous maintenance log''s of all equipment in register or soft copy.
5) Periodic maintenance schedule  for equipment as per point no "f" in checking method',
    '1) BP Tools & Equipment Annexure and guidebook',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ042',
    'v1-DQ042-004',
    'Facility',
    'Workshop',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Facility',
    'Workshop',
    'Recommended paint preparation & top coating equipment availability & Usage - Dual action sander, dust collector, infrared dryer, spray gun, paint mixing scale, Air dryer unit, polishing pad',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Indirect',
    '3S',
    'Recommended paint preparation & top coating equipment availability & Usage - Dual action sander, dust collector, infrared dryer, spray gun, paint mixing scale, Air dryer unit, polishing pad',
    '*To ensure repair quality by possessing and using the necessary tools & equipment

*To ensure welding repair quality',
    '1) Check for availability and usage condition of listed tools & equipment in body repair process 
- Frame aligner, Tracking gauge (Calibration), Safety wire, Air saw, MAG welder, Spot welder, Hemming tool, Straight edge, washer welder, single action / roloc sander
2) Check if hydraulic equipment work normally and there is no oil leakage.
3) Check If there is no excessive gap between the MAG Welder contact tip''s central hole and wire and no obvious spatter adhered inside the nozzle
4) Check for availability and usage condition of listed tools & equipment in paint repair process 
- Dual action sander, dust collection equipment, infrared dryer, Spray gun, paint mixing scale (calibrated), Oil-water separator(Air dryer unit).
5) Check If paint booth walls / floor are free from dust and no sagging & clogging of roof filter and exhaust filters.
6) Check for regular maintenance check sheet available (Daily / Weekly / Monthly / Annually) along with PIC & updated as per current date for all the quipments
7) Check all paint containers are closed properly and buffing pad 4S condition. 
8) Check whether Tools & Equipment are assigned dedicated location with clear demarcation.
9) Check the availability & usage of listed consumables in body & paint repair process
- Body sealant, undercoat, rust proofing, resin adhesive, Urethane surfacer, masking materials, paint strainer *Refer the T&E annexure for details',
    '1) Visually confirm the mentioned tools & equipment condition and usage.
2) Paint booth cleaning process charts display.
3) Visually confirm the availability of maintenance sheet attached with each equipment and the same is duly updated.
4) Records of previous maintenance log''s of all equipment in register or soft copy.
5) Periodic maintenance schedule  for equipment as per point no "f" in checking method',
    '1) BP Tools & Equipment Annexure and guidebook',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ042',
    'v1-DQ042-005',
    'Facility',
    'Workshop',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Facility',
    'Workshop',
    'BP Paint booth cleaning, & Maintenance as per Standard [Refer Vendor Do''s & Don''ts Guideline]',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Indirect',
    '3S',
    'BP Paint booth cleaning, & Maintenance as per Standard [Refer Vendor Do''s & Don''ts Guideline]',
    '*To ensure repair quality by possessing and using the necessary tools & equipment

*To ensure welding repair quality',
    '1) Check for availability and usage condition of listed tools & equipment in body repair process 
- Frame aligner, Tracking gauge (Calibration), Safety wire, Air saw, MAG welder, Spot welder, Hemming tool, Straight edge, washer welder, single action / roloc sander
2) Check if hydraulic equipment work normally and there is no oil leakage.
3) Check If there is no excessive gap between the MAG Welder contact tip''s central hole and wire and no obvious spatter adhered inside the nozzle
4) Check for availability and usage condition of listed tools & equipment in paint repair process 
- Dual action sander, dust collection equipment, infrared dryer, Spray gun, paint mixing scale (calibrated), Oil-water separator(Air dryer unit).
5) Check If paint booth walls / floor are free from dust and no sagging & clogging of roof filter and exhaust filters.
6) Check for regular maintenance check sheet available (Daily / Weekly / Monthly / Annually) along with PIC & updated as per current date for all the quipments
7) Check all paint containers are closed properly and buffing pad 4S condition. 
8) Check whether Tools & Equipment are assigned dedicated location with clear demarcation.
9) Check the availability & usage of listed consumables in body & paint repair process
- Body sealant, undercoat, rust proofing, resin adhesive, Urethane surfacer, masking materials, paint strainer *Refer the T&E annexure for details',
    '1) Visually confirm the mentioned tools & equipment condition and usage.
2) Paint booth cleaning process charts display.
3) Visually confirm the availability of maintenance sheet attached with each equipment and the same is duly updated.
4) Records of previous maintenance log''s of all equipment in register or soft copy.
5) Periodic maintenance schedule  for equipment as per point no "f" in checking method',
    '1) BP Tools & Equipment Annexure and guidebook',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ042',
    'v1-DQ042-006',
    'Facility',
    'Workshop',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Facility',
    'Workshop',
    'All tools & Equipment maintenance management & consumable availability.',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Indirect',
    '3S',
    'All tools & Equipment maintenance management & consumable availability.',
    '*To ensure repair quality by possessing and using the necessary tools & equipment

*To ensure welding repair quality',
    '1) Check for availability and usage condition of listed tools & equipment in body repair process 
- Frame aligner, Tracking gauge (Calibration), Safety wire, Air saw, MAG welder, Spot welder, Hemming tool, Straight edge, washer welder, single action / roloc sander
2) Check if hydraulic equipment work normally and there is no oil leakage.
3) Check If there is no excessive gap between the MAG Welder contact tip''s central hole and wire and no obvious spatter adhered inside the nozzle
4) Check for availability and usage condition of listed tools & equipment in paint repair process 
- Dual action sander, dust collection equipment, infrared dryer, Spray gun, paint mixing scale (calibrated), Oil-water separator(Air dryer unit).
5) Check If paint booth walls / floor are free from dust and no sagging & clogging of roof filter and exhaust filters.
6) Check for regular maintenance check sheet available (Daily / Weekly / Monthly / Annually) along with PIC & updated as per current date for all the quipments
7) Check all paint containers are closed properly and buffing pad 4S condition. 
8) Check whether Tools & Equipment are assigned dedicated location with clear demarcation.
9) Check the availability & usage of listed consumables in body & paint repair process
- Body sealant, undercoat, rust proofing, resin adhesive, Urethane surfacer, masking materials, paint strainer *Refer the T&E annexure for details',
    '1) Visually confirm the mentioned tools & equipment condition and usage.
2) Paint booth cleaning process charts display.
3) Visually confirm the availability of maintenance sheet attached with each equipment and the same is duly updated.
4) Records of previous maintenance log''s of all equipment in register or soft copy.
5) Periodic maintenance schedule  for equipment as per point no "f" in checking method',
    '1) BP Tools & Equipment Annexure and guidebook',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ042',
    'v1-DQ042-007',
    'Facility',
    'Workshop',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Facility',
    'Workshop',
    'Paint mixing room 4S condition with ventillation from bottom & paint containers lid are closed.',
    'Does dealer has the Availability & Usage of the following tools/equipment in BP service workshop as per TKM Recommendation?',
    'Indirect',
    '3S',
    'Paint mixing room 4S condition with ventillation from bottom & paint containers lid are closed.',
    '*To ensure repair quality by possessing and using the necessary tools & equipment

*To ensure welding repair quality',
    '1) Check for availability and usage condition of listed tools & equipment in body repair process 
- Frame aligner, Tracking gauge (Calibration), Safety wire, Air saw, MAG welder, Spot welder, Hemming tool, Straight edge, washer welder, single action / roloc sander
2) Check if hydraulic equipment work normally and there is no oil leakage.
3) Check If there is no excessive gap between the MAG Welder contact tip''s central hole and wire and no obvious spatter adhered inside the nozzle
4) Check for availability and usage condition of listed tools & equipment in paint repair process 
- Dual action sander, dust collection equipment, infrared dryer, Spray gun, paint mixing scale (calibrated), Oil-water separator(Air dryer unit).
5) Check If paint booth walls / floor are free from dust and no sagging & clogging of roof filter and exhaust filters.
6) Check for regular maintenance check sheet available (Daily / Weekly / Monthly / Annually) along with PIC & updated as per current date for all the quipments
7) Check all paint containers are closed properly and buffing pad 4S condition. 
8) Check whether Tools & Equipment are assigned dedicated location with clear demarcation.
9) Check the availability & usage of listed consumables in body & paint repair process
- Body sealant, undercoat, rust proofing, resin adhesive, Urethane surfacer, masking materials, paint strainer *Refer the T&E annexure for details',
    '1) Visually confirm the mentioned tools & equipment condition and usage.
2) Paint booth cleaning process charts display.
3) Visually confirm the availability of maintenance sheet attached with each equipment and the same is duly updated.
4) Records of previous maintenance log''s of all equipment in register or soft copy.
5) Periodic maintenance schedule  for equipment as per point no "f" in checking method',
    '1) BP Tools & Equipment Annexure and guidebook',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ043',
    'v1-DQ043-001',
    'Operation [Service]',
    'Workshop',
    '[Production management]
Does dealer staff performs Repair Planning & Progress Monitoring in BP SMB (Service Management Board) or Manual / excel job progress control (JPB) board?',
    'Operation [Service]',
    'Workshop',
    'Job workder order is created by BP Service Advisor and job plan by Job controller as per job planning SOP.',
    '[Production management]
Does dealer staff performs Repair Planning & Progress Monitoring in BP SMB (Service Management Board) or Manual / excel job progress control (JPB) board?',
    'Indirect',
    '3S',
    'Job workder order is created by BP Service Advisor and job plan by Job controller as per job planning SOP.',
    '*To enable Guests to be notified of delivery timings based on available times in the work schedule (i.e.., as per workshop condition) also ensures to understand the work load for the each day.',
    '1) Check if job workorder is created & planned in BP SMB or JPB (manual / excel), for all approved jobs (insurance / customer) with parts ETA. Also check & Confirm dealer staff performing repair planning are aware about job planning SOP
2) Status in BP SMB matches the actual Job progress status for each process in workshop
3) Reason for job stoppage and job resuming date are updated in the documents kept in the control board (both Front office & Shop floor).
4) Job stoppage vehicles are parked in designated bays and can be identified easily
5) Check if job start time and finish time is accurately updates in BP SMB (recorded in document incase BP SMB not implemented)',
    '1) Workorder is created for each RO post parts confirmation
2) Standard operation guidelines for BP SMB or similar control tool with PIC display.
3) RO is sent to workshop along with Workorder 
4) Vehicle status hanger displayed in vehicle.
5) Job stoppage slip on folder and vehicle.',
    '1) BP SOP (Swayam Portal)
2) BP SMB e-Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ043',
    'v1-DQ043-002',
    'Operation [Service]',
    'Workshop',
    '[Production management]
Does dealer staff performs Repair Planning & Progress Monitoring in BP SMB (Service Management Board) or Manual / excel job progress control (JPB) board?',
    'Operation [Service]',
    'Workshop',
    'Status of vehicle progress shown in BP SMB matches with actual condition.',
    '[Production management]
Does dealer staff performs Repair Planning & Progress Monitoring in BP SMB (Service Management Board) or Manual / excel job progress control (JPB) board?',
    'Indirect',
    '3S',
    'Status of vehicle progress shown in BP SMB matches with actual condition.',
    '*To enable Guests to be notified of delivery timings based on available times in the work schedule (i.e.., as per workshop condition) also ensures to understand the work load for the each day.',
    '1) Check if job workorder is created & planned in BP SMB or JPB (manual / excel), for all approved jobs (insurance / customer) with parts ETA. Also check & Confirm dealer staff performing repair planning are aware about job planning SOP
2) Status in BP SMB matches the actual Job progress status for each process in workshop
3) Reason for job stoppage and job resuming date are updated in the documents kept in the control board (both Front office & Shop floor).
4) Job stoppage vehicles are parked in designated bays and can be identified easily
5) Check if job start time and finish time is accurately updates in BP SMB (recorded in document incase BP SMB not implemented)',
    '1) Workorder is created for each RO post parts confirmation
2) Standard operation guidelines for BP SMB or similar control tool with PIC display.
3) RO is sent to workshop along with Workorder 
4) Vehicle status hanger displayed in vehicle.
5) Job stoppage slip on folder and vehicle.',
    '1) BP SOP (Swayam Portal)
2) BP SMB e-Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ043',
    'v1-DQ043-003',
    'Operation [Service]',
    'Workshop',
    '[Production management]
Does dealer staff performs Repair Planning & Progress Monitoring in BP SMB (Service Management Board) or Manual / excel job progress control (JPB) board?',
    'Operation [Service]',
    'Workshop',
    'Job stoppage vehicle',
    '[Production management]
Does dealer staff performs Repair Planning & Progress Monitoring in BP SMB (Service Management Board) or Manual / excel job progress control (JPB) board?',
    'Indirect',
    '3S',
    'Job stoppage vehicle',
    '*To enable Guests to be notified of delivery timings based on available times in the work schedule (i.e.., as per workshop condition) also ensures to understand the work load for the each day.',
    '1) Check if job workorder is created & planned in BP SMB or JPB (manual / excel), for all approved jobs (insurance / customer) with parts ETA. Also check & Confirm dealer staff performing repair planning are aware about job planning SOP
2) Status in BP SMB matches the actual Job progress status for each process in workshop
3) Reason for job stoppage and job resuming date are updated in the documents kept in the control board (both Front office & Shop floor).
4) Job stoppage vehicles are parked in designated bays and can be identified easily
5) Check if job start time and finish time is accurately updates in BP SMB (recorded in document incase BP SMB not implemented)',
    '1) Workorder is created for each RO post parts confirmation
2) Standard operation guidelines for BP SMB or similar control tool with PIC display.
3) RO is sent to workshop along with Workorder 
4) Vehicle status hanger displayed in vehicle.
5) Job stoppage slip on folder and vehicle.',
    '1) BP SOP (Swayam Portal)
2) BP SMB e-Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ044',
    'v1-DQ044-001',
    'Operation [Service]',
    'Workshop',
    '[Repair Quality management]
Does dealer performs quality inspection check for all BP vehicles as per distributor guidelines?',
    'Operation [Service]',
    'Workshop',
    'In-Process Check sheet availability and usage in both body & paint repair process.',
    '[Repair Quality management]
Does dealer performs quality inspection check for all BP vehicles as per distributor guidelines?',
    'Direct',
    '3S',
    'In-Process Check sheet availability and usage in both body & paint repair process.',
    '* To ensure the quality of completed vehicles by performing quality checks in each process so that defects do not get passed on to downstream processes',
    '1) Check if In-process quality check (after each process) & final inspect is done and the result is updated in QC sheet for each process.
2) Check only putty dry sanding is performed in the workshop - and No Wet Sanding
3) Check if technician refers Body Repair Manual for frame alignment and panel replacement jobs.
4) Check if shower test is done for glass replacement work and result is recorded in final inspection check sheet.',
    '1) In-Process check sheet & Final Inspection check sheet document.
2) Poster display of Good and NG [Not Good] quality for each process in the stall.
3) Quality repair guide availability and usage for internal training.
4) Visually confirm the putty repair stall (no water in the stall)',
    '1) BP SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ044',
    'v1-DQ044-002',
    'Operation [Service]',
    'Workshop',
    '[Repair Quality management]
Does dealer performs quality inspection check for all BP vehicles as per distributor guidelines?',
    'Operation [Service]',
    'Workshop',
    'Final Inspection check sheet availability and usage',
    '[Repair Quality management]
Does dealer performs quality inspection check for all BP vehicles as per distributor guidelines?',
    'Direct',
    '3S',
    'Final Inspection check sheet availability and usage',
    '* To ensure the quality of completed vehicles by performing quality checks in each process so that defects do not get passed on to downstream processes',
    '1) Check if In-process quality check (after each process) & final inspect is done and the result is updated in QC sheet for each process.
2) Check only putty dry sanding is performed in the workshop - and No Wet Sanding
3) Check if technician refers Body Repair Manual for frame alignment and panel replacement jobs.
4) Check if shower test is done for glass replacement work and result is recorded in final inspection check sheet.',
    '1) In-Process check sheet & Final Inspection check sheet document.
2) Poster display of Good and NG [Not Good] quality for each process in the stall.
3) Quality repair guide availability and usage for internal training.
4) Visually confirm the putty repair stall (no water in the stall)',
    '1) BP SOP (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ045',
    'v1-DQ045-001',
    'Safety & Environment',
    'Workshop',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Safety & Environment',
    'Workshop',
    'Technician using proper PPEs (Personal Protective equipment as per process guidelines while working.)',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Indirect',
    '3S',
    'Technician using proper PPEs (Personal Protective equipment as per process guidelines while working.)',
    '* Ensuring a Safe workplace is a prerequisite for preventing Accidents/Incidents/ Damages/ ill health',
    '1) Check usage of appropriate PPE by member as per process; Technicians must not be working under vehicle without helmet and vehicles not left on lift when no work done on vehicle for long time (>15 mins). Lift operation done after checking for no man movement. Call out process must when more than one technician work on a bay(ex. EM bay).
2) Precautionary steps at workstation to minimize hazard (Electrical, Inflammable storage etc.)
3) Safety Promotion activity by Dealer Self and Involvement in TKM Safety activity (e.g. Hiyari Hatto, 4S, Campaigns, Yokoten)
4) Check for Safety precautions - Load testing certificate for Lift, Hoist etc.; safety precautions for people working at a height, electric zones; proper storage of items stored at an height.
5) Check the Paint Booths AMC with OE Supplier and its validity (date mentioned in the agreement)
6) Check and validate any rectification suggested during AMC check by OE Supplier is rectified appropriately by competent technician
7) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
8) Chart showing correct location of all fire extinguishers
9) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken',
    '1) Check actual PPE usage at every process (e.g. Grinding, Wheel alignment, body alignment, painting, Paint mixing, Welding, Periodic maintenance, Washing, VAS area), visitors safety mechanism
2) Plan of Periodic Maintenance of Equipment (including Electrical) are visualized and evidence of maintenance performed as per plan viz. check sheet, Plan Vs Actual, & History of Logbook
- Valid Load testing certificate , Quality parameter
- Precautions available at facility to minimize risks / accidents (e.g. precautions to prevent Fall of persons working at higher level above the floor, precautions are taken to prevent drop of items stored above floor level, electrical connections are well insulated to prevent electrocuted).
- Periodic Maintenance of Equipment are visualized. Review Basic Safety implementation to minimize risks, Pre-operation check sheets
- Implementation of Safety check sheet shared by TKM and Paint booth AMC
[Fire Hazard]
1) Check Fire Fighting Equipment & Hydrant system . - Fire fighting equipment maintenance by authorized persons, audit records, updated monthly check card with every Fire Extinguisher unit  
2) Mock Drills involving all staff, Fire Fighting trainings - at least 1/year. Photos, report & training record',
    '1) BP SOP (Swayam Portal)
2) BP Safety PPE Annexure',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ045',
    'v1-DQ045-002',
    'Safety & Environment',
    'Workshop',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Safety & Environment',
    'Workshop',
    'Precautionary steps at workstation to minimize accidents (hazards',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Indirect',
    '3S',
    'Precautionary steps at workstation to minimize accidents (hazards',
    '* Ensuring a Safe workplace is a prerequisite for preventing Accidents/Incidents/ Damages/ ill health',
    '1) Check usage of appropriate PPE by member as per process; Technicians must not be working under vehicle without helmet and vehicles not left on lift when no work done on vehicle for long time (>15 mins). Lift operation done after checking for no man movement. Call out process must when more than one technician work on a bay(ex. EM bay).
2) Precautionary steps at workstation to minimize hazard (Electrical, Inflammable storage etc.)
3) Safety Promotion activity by Dealer Self and Involvement in TKM Safety activity (e.g. Hiyari Hatto, 4S, Campaigns, Yokoten)
4) Check for Safety precautions - Load testing certificate for Lift, Hoist etc.; safety precautions for people working at a height, electric zones; proper storage of items stored at an height.
5) Check the Paint Booths AMC with OE Supplier and its validity (date mentioned in the agreement)
6) Check and validate any rectification suggested during AMC check by OE Supplier is rectified appropriately by competent technician
7) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
8) Chart showing correct location of all fire extinguishers
9) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken',
    '1) Check actual PPE usage at every process (e.g. Grinding, Wheel alignment, body alignment, painting, Paint mixing, Welding, Periodic maintenance, Washing, VAS area), visitors safety mechanism
2) Plan of Periodic Maintenance of Equipment (including Electrical) are visualized and evidence of maintenance performed as per plan viz. check sheet, Plan Vs Actual, & History of Logbook
- Valid Load testing certificate , Quality parameter
- Precautions available at facility to minimize risks / accidents (e.g. precautions to prevent Fall of persons working at higher level above the floor, precautions are taken to prevent drop of items stored above floor level, electrical connections are well insulated to prevent electrocuted).
- Periodic Maintenance of Equipment are visualized. Review Basic Safety implementation to minimize risks, Pre-operation check sheets
- Implementation of Safety check sheet shared by TKM and Paint booth AMC
[Fire Hazard]
1) Check Fire Fighting Equipment & Hydrant system . - Fire fighting equipment maintenance by authorized persons, audit records, updated monthly check card with every Fire Extinguisher unit  
2) Mock Drills involving all staff, Fire Fighting trainings - at least 1/year. Photos, report & training record',
    '1) BP SOP (Swayam Portal)
2) BP Safety PPE Annexure',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ045',
    'v1-DQ045-003',
    'Safety & Environment',
    'Workshop',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Safety & Environment',
    'Workshop',
    'Dealer implemented safety promotion activity for awareness and training of all members, mock drills, safety calendar in workshop',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Indirect',
    '3S',
    'Dealer implemented safety promotion activity for awareness and training of all members, mock drills, safety calendar in workshop',
    '* Ensuring a Safe workplace is a prerequisite for preventing Accidents/Incidents/ Damages/ ill health',
    '1) Check usage of appropriate PPE by member as per process; Technicians must not be working under vehicle without helmet and vehicles not left on lift when no work done on vehicle for long time (>15 mins). Lift operation done after checking for no man movement. Call out process must when more than one technician work on a bay(ex. EM bay).
2) Precautionary steps at workstation to minimize hazard (Electrical, Inflammable storage etc.)
3) Safety Promotion activity by Dealer Self and Involvement in TKM Safety activity (e.g. Hiyari Hatto, 4S, Campaigns, Yokoten)
4) Check for Safety precautions - Load testing certificate for Lift, Hoist etc.; safety precautions for people working at a height, electric zones; proper storage of items stored at an height.
5) Check the Paint Booths AMC with OE Supplier and its validity (date mentioned in the agreement)
6) Check and validate any rectification suggested during AMC check by OE Supplier is rectified appropriately by competent technician
7) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
8) Chart showing correct location of all fire extinguishers
9) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken',
    '1) Check actual PPE usage at every process (e.g. Grinding, Wheel alignment, body alignment, painting, Paint mixing, Welding, Periodic maintenance, Washing, VAS area), visitors safety mechanism
2) Plan of Periodic Maintenance of Equipment (including Electrical) are visualized and evidence of maintenance performed as per plan viz. check sheet, Plan Vs Actual, & History of Logbook
- Valid Load testing certificate , Quality parameter
- Precautions available at facility to minimize risks / accidents (e.g. precautions to prevent Fall of persons working at higher level above the floor, precautions are taken to prevent drop of items stored above floor level, electrical connections are well insulated to prevent electrocuted).
- Periodic Maintenance of Equipment are visualized. Review Basic Safety implementation to minimize risks, Pre-operation check sheets
- Implementation of Safety check sheet shared by TKM and Paint booth AMC
[Fire Hazard]
1) Check Fire Fighting Equipment & Hydrant system . - Fire fighting equipment maintenance by authorized persons, audit records, updated monthly check card with every Fire Extinguisher unit  
2) Mock Drills involving all staff, Fire Fighting trainings - at least 1/year. Photos, report & training record',
    '1) BP SOP (Swayam Portal)
2) BP Safety PPE Annexure',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ045',
    'v1-DQ045-004',
    'Safety & Environment',
    'Workshop',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Safety & Environment',
    'Workshop',
    'Safety measures taken while working on lift, hieght, electic zones',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Indirect',
    '3S',
    'Safety measures taken while working on lift, hieght, electic zones',
    '* Ensuring a Safe workplace is a prerequisite for preventing Accidents/Incidents/ Damages/ ill health',
    '1) Check usage of appropriate PPE by member as per process; Technicians must not be working under vehicle without helmet and vehicles not left on lift when no work done on vehicle for long time (>15 mins). Lift operation done after checking for no man movement. Call out process must when more than one technician work on a bay(ex. EM bay).
2) Precautionary steps at workstation to minimize hazard (Electrical, Inflammable storage etc.)
3) Safety Promotion activity by Dealer Self and Involvement in TKM Safety activity (e.g. Hiyari Hatto, 4S, Campaigns, Yokoten)
4) Check for Safety precautions - Load testing certificate for Lift, Hoist etc.; safety precautions for people working at a height, electric zones; proper storage of items stored at an height.
5) Check the Paint Booths AMC with OE Supplier and its validity (date mentioned in the agreement)
6) Check and validate any rectification suggested during AMC check by OE Supplier is rectified appropriately by competent technician
7) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
8) Chart showing correct location of all fire extinguishers
9) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken',
    '1) Check actual PPE usage at every process (e.g. Grinding, Wheel alignment, body alignment, painting, Paint mixing, Welding, Periodic maintenance, Washing, VAS area), visitors safety mechanism
2) Plan of Periodic Maintenance of Equipment (including Electrical) are visualized and evidence of maintenance performed as per plan viz. check sheet, Plan Vs Actual, & History of Logbook
- Valid Load testing certificate , Quality parameter
- Precautions available at facility to minimize risks / accidents (e.g. precautions to prevent Fall of persons working at higher level above the floor, precautions are taken to prevent drop of items stored above floor level, electrical connections are well insulated to prevent electrocuted).
- Periodic Maintenance of Equipment are visualized. Review Basic Safety implementation to minimize risks, Pre-operation check sheets
- Implementation of Safety check sheet shared by TKM and Paint booth AMC
[Fire Hazard]
1) Check Fire Fighting Equipment & Hydrant system . - Fire fighting equipment maintenance by authorized persons, audit records, updated monthly check card with every Fire Extinguisher unit  
2) Mock Drills involving all staff, Fire Fighting trainings - at least 1/year. Photos, report & training record',
    '1) BP SOP (Swayam Portal)
2) BP Safety PPE Annexure',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ045',
    'v1-DQ045-005',
    'Safety & Environment',
    'Workshop',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Safety & Environment',
    'Workshop',
    'Check if there is a valid AMC for Paint Booth available with OE Supplier and it is effectively used i.e. any rectification is timely carried out',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Indirect',
    '3S',
    'Check if there is a valid AMC for Paint Booth available with OE Supplier and it is effectively used i.e. any rectification is timely carried out',
    '* Ensuring a Safe workplace is a prerequisite for preventing Accidents/Incidents/ Damages/ ill health',
    '1) Check usage of appropriate PPE by member as per process; Technicians must not be working under vehicle without helmet and vehicles not left on lift when no work done on vehicle for long time (>15 mins). Lift operation done after checking for no man movement. Call out process must when more than one technician work on a bay(ex. EM bay).
2) Precautionary steps at workstation to minimize hazard (Electrical, Inflammable storage etc.)
3) Safety Promotion activity by Dealer Self and Involvement in TKM Safety activity (e.g. Hiyari Hatto, 4S, Campaigns, Yokoten)
4) Check for Safety precautions - Load testing certificate for Lift, Hoist etc.; safety precautions for people working at a height, electric zones; proper storage of items stored at an height.
5) Check the Paint Booths AMC with OE Supplier and its validity (date mentioned in the agreement)
6) Check and validate any rectification suggested during AMC check by OE Supplier is rectified appropriately by competent technician
7) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
8) Chart showing correct location of all fire extinguishers
9) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken',
    '1) Check actual PPE usage at every process (e.g. Grinding, Wheel alignment, body alignment, painting, Paint mixing, Welding, Periodic maintenance, Washing, VAS area), visitors safety mechanism
2) Plan of Periodic Maintenance of Equipment (including Electrical) are visualized and evidence of maintenance performed as per plan viz. check sheet, Plan Vs Actual, & History of Logbook
- Valid Load testing certificate , Quality parameter
- Precautions available at facility to minimize risks / accidents (e.g. precautions to prevent Fall of persons working at higher level above the floor, precautions are taken to prevent drop of items stored above floor level, electrical connections are well insulated to prevent electrocuted).
- Periodic Maintenance of Equipment are visualized. Review Basic Safety implementation to minimize risks, Pre-operation check sheets
- Implementation of Safety check sheet shared by TKM and Paint booth AMC
[Fire Hazard]
1) Check Fire Fighting Equipment & Hydrant system . - Fire fighting equipment maintenance by authorized persons, audit records, updated monthly check card with every Fire Extinguisher unit  
2) Mock Drills involving all staff, Fire Fighting trainings - at least 1/year. Photos, report & training record',
    '1) BP SOP (Swayam Portal)
2) BP Safety PPE Annexure',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ045',
    'v1-DQ045-006',
    'Safety & Environment',
    'Workshop',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Safety & Environment',
    'Workshop',
    'Emergency evacuation are visualized inside the workshop',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Indirect',
    '3S',
    'Emergency evacuation are visualized inside the workshop',
    '* Ensuring a Safe workplace is a prerequisite for preventing Accidents/Incidents/ Damages/ ill health',
    '1) Check usage of appropriate PPE by member as per process; Technicians must not be working under vehicle without helmet and vehicles not left on lift when no work done on vehicle for long time (>15 mins). Lift operation done after checking for no man movement. Call out process must when more than one technician work on a bay(ex. EM bay).
2) Precautionary steps at workstation to minimize hazard (Electrical, Inflammable storage etc.)
3) Safety Promotion activity by Dealer Self and Involvement in TKM Safety activity (e.g. Hiyari Hatto, 4S, Campaigns, Yokoten)
4) Check for Safety precautions - Load testing certificate for Lift, Hoist etc.; safety precautions for people working at a height, electric zones; proper storage of items stored at an height.
5) Check the Paint Booths AMC with OE Supplier and its validity (date mentioned in the agreement)
6) Check and validate any rectification suggested during AMC check by OE Supplier is rectified appropriately by competent technician
7) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
8) Chart showing correct location of all fire extinguishers
9) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken',
    '1) Check actual PPE usage at every process (e.g. Grinding, Wheel alignment, body alignment, painting, Paint mixing, Welding, Periodic maintenance, Washing, VAS area), visitors safety mechanism
2) Plan of Periodic Maintenance of Equipment (including Electrical) are visualized and evidence of maintenance performed as per plan viz. check sheet, Plan Vs Actual, & History of Logbook
- Valid Load testing certificate , Quality parameter
- Precautions available at facility to minimize risks / accidents (e.g. precautions to prevent Fall of persons working at higher level above the floor, precautions are taken to prevent drop of items stored above floor level, electrical connections are well insulated to prevent electrocuted).
- Periodic Maintenance of Equipment are visualized. Review Basic Safety implementation to minimize risks, Pre-operation check sheets
- Implementation of Safety check sheet shared by TKM and Paint booth AMC
[Fire Hazard]
1) Check Fire Fighting Equipment & Hydrant system . - Fire fighting equipment maintenance by authorized persons, audit records, updated monthly check card with every Fire Extinguisher unit  
2) Mock Drills involving all staff, Fire Fighting trainings - at least 1/year. Photos, report & training record',
    '1) BP SOP (Swayam Portal)
2) BP Safety PPE Annexure',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ045',
    'v1-DQ045-007',
    'Safety & Environment',
    'Workshop',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Safety & Environment',
    'Workshop',
    'Emergency handling equipments are in operational condition (Firefighting & Emergency Contact',
    'Does the dealer maintain a Safe workplace with safety precautions?',
    'Indirect',
    '3S',
    'Emergency handling equipments are in operational condition (Firefighting & Emergency Contact',
    '* Ensuring a Safe workplace is a prerequisite for preventing Accidents/Incidents/ Damages/ ill health',
    '1) Check usage of appropriate PPE by member as per process; Technicians must not be working under vehicle without helmet and vehicles not left on lift when no work done on vehicle for long time (>15 mins). Lift operation done after checking for no man movement. Call out process must when more than one technician work on a bay(ex. EM bay).
2) Precautionary steps at workstation to minimize hazard (Electrical, Inflammable storage etc.)
3) Safety Promotion activity by Dealer Self and Involvement in TKM Safety activity (e.g. Hiyari Hatto, 4S, Campaigns, Yokoten)
4) Check for Safety precautions - Load testing certificate for Lift, Hoist etc.; safety precautions for people working at a height, electric zones; proper storage of items stored at an height.
5) Check the Paint Booths AMC with OE Supplier and its validity (date mentioned in the agreement)
6) Check and validate any rectification suggested during AMC check by OE Supplier is rectified appropriately by competent technician
7) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
8) Chart showing correct location of all fire extinguishers
9) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken',
    '1) Check actual PPE usage at every process (e.g. Grinding, Wheel alignment, body alignment, painting, Paint mixing, Welding, Periodic maintenance, Washing, VAS area), visitors safety mechanism
2) Plan of Periodic Maintenance of Equipment (including Electrical) are visualized and evidence of maintenance performed as per plan viz. check sheet, Plan Vs Actual, & History of Logbook
- Valid Load testing certificate , Quality parameter
- Precautions available at facility to minimize risks / accidents (e.g. precautions to prevent Fall of persons working at higher level above the floor, precautions are taken to prevent drop of items stored above floor level, electrical connections are well insulated to prevent electrocuted).
- Periodic Maintenance of Equipment are visualized. Review Basic Safety implementation to minimize risks, Pre-operation check sheets
- Implementation of Safety check sheet shared by TKM and Paint booth AMC
[Fire Hazard]
1) Check Fire Fighting Equipment & Hydrant system . - Fire fighting equipment maintenance by authorized persons, audit records, updated monthly check card with every Fire Extinguisher unit  
2) Mock Drills involving all staff, Fire Fighting trainings - at least 1/year. Photos, report & training record',
    '1) BP SOP (Swayam Portal)
2) BP Safety PPE Annexure',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ046',
    'v1-DQ046-001',
    'Operation [Service]',
    'Washing',
    'Does Dealer ensure below Washing related standards?',
    'Operation [Service]',
    'Washing',
    'Washing Process has a clearly defined SWP & washing guidelines ( Do''s & Don''ts',
    'Does Dealer ensure below Washing related standards?',
    'Direct',
    '3S',
    'Washing Process has a clearly defined SWP & washing guidelines ( Do''s & Don''ts',
    '* Ensure High quality washing with in the set cycle time

* Quality Gate 3 rejection data analysis will ensure gap identification, Countermeasure and Manpower development',
    '1) Check for the SOP availability and observe the process to confirm if SOP is followed and work completed with in set cycle time
2) Vehicles must be prioritized for washing based on the sequence in wash supervisor''s iPad or through other means like washing prioritization board / communication from JC to wash area (in case of no e-CRB), and in case there are 2 or more vehicles with same delivery time, EM & waiting Guest vehicle is prioritized.
3) Check for availability /usage of the washing materials. The Condition of Cloth used for washing has to be good.
5) Check existence of Quality Gate 3 inspector with clear R&R, Washing Checklist availability & Usage including QG#3 checkpoints with rejections
6) Service Manager Review mechanism of all Quality Gate 3 concerns & proofs (Action plan)',
    '1) The SWP should carry the following information
- Steps / Sequence of operations [What/When]
- Manpower details [Who]
- Tools used
- Washing training video is an effective tool to train staff on the washing
2) QG#3 Seal, Washing Check sheet, Q Talk Card, VOC shared proof, Daily discussion by Supervisor proof (register), Action plan based on analysis',
    '1) GS SOP Washing (Swayam Portal)
2) TSM FIR Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ046',
    'v1-DQ046-002',
    'Operation [Service]',
    'Washing',
    'Does Dealer ensure below Washing related standards?',
    'Operation [Service]',
    'Washing',
    'Washing cycle time is set considering the peak load and EM 60 mins target and the washing is completed with in the set cycle time',
    'Does Dealer ensure below Washing related standards?',
    'Direct',
    '3S',
    'Washing cycle time is set considering the peak load and EM 60 mins target and the washing is completed with in the set cycle time',
    '* Ensure High quality washing with in the set cycle time

* Quality Gate 3 rejection data analysis will ensure gap identification, Countermeasure and Manpower development',
    '1) Check for the SOP availability and observe the process to confirm if SOP is followed and work completed with in set cycle time
2) Vehicles must be prioritized for washing based on the sequence in wash supervisor''s iPad or through other means like washing prioritization board / communication from JC to wash area (in case of no e-CRB), and in case there are 2 or more vehicles with same delivery time, EM & waiting Guest vehicle is prioritized.
3) Check for availability /usage of the washing materials. The Condition of Cloth used for washing has to be good.
5) Check existence of Quality Gate 3 inspector with clear R&R, Washing Checklist availability & Usage including QG#3 checkpoints with rejections
6) Service Manager Review mechanism of all Quality Gate 3 concerns & proofs (Action plan)',
    '1) The SWP should carry the following information
- Steps / Sequence of operations [What/When]
- Manpower details [Who]
- Tools used
- Washing training video is an effective tool to train staff on the washing
2) QG#3 Seal, Washing Check sheet, Q Talk Card, VOC shared proof, Daily discussion by Supervisor proof (register), Action plan based on analysis',
    '1) GS SOP Washing (Swayam Portal)
2) TSM FIR Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ046',
    'v1-DQ046-003',
    'Operation [Service]',
    'Washing',
    'Does Dealer ensure below Washing related standards?',
    'Operation [Service]',
    'Washing',
    'Vehicles are prioritized in washing based on delivery time, waiting status & EM applicability.',
    'Does Dealer ensure below Washing related standards?',
    'Direct',
    '3S',
    'Vehicles are prioritized in washing based on delivery time, waiting status & EM applicability.',
    '* Ensure High quality washing with in the set cycle time

* Quality Gate 3 rejection data analysis will ensure gap identification, Countermeasure and Manpower development',
    '1) Check for the SOP availability and observe the process to confirm if SOP is followed and work completed with in set cycle time
2) Vehicles must be prioritized for washing based on the sequence in wash supervisor''s iPad or through other means like washing prioritization board / communication from JC to wash area (in case of no e-CRB), and in case there are 2 or more vehicles with same delivery time, EM & waiting Guest vehicle is prioritized.
3) Check for availability /usage of the washing materials. The Condition of Cloth used for washing has to be good.
5) Check existence of Quality Gate 3 inspector with clear R&R, Washing Checklist availability & Usage including QG#3 checkpoints with rejections
6) Service Manager Review mechanism of all Quality Gate 3 concerns & proofs (Action plan)',
    '1) The SWP should carry the following information
- Steps / Sequence of operations [What/When]
- Manpower details [Who]
- Tools used
- Washing training video is an effective tool to train staff on the washing
2) QG#3 Seal, Washing Check sheet, Q Talk Card, VOC shared proof, Daily discussion by Supervisor proof (register), Action plan based on analysis',
    '1) GS SOP Washing (Swayam Portal)
2) TSM FIR Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ046',
    'v1-DQ046-004',
    'Operation [Service]',
    'Washing',
    'Does Dealer ensure below Washing related standards?',
    'Operation [Service]',
    'Washing',
    'TKM Recommended washing Materials & Chemicals are used.',
    'Does Dealer ensure below Washing related standards?',
    'Direct',
    '3S',
    'TKM Recommended washing Materials & Chemicals are used.',
    '* Ensure High quality washing with in the set cycle time

* Quality Gate 3 rejection data analysis will ensure gap identification, Countermeasure and Manpower development',
    '1) Check for the SOP availability and observe the process to confirm if SOP is followed and work completed with in set cycle time
2) Vehicles must be prioritized for washing based on the sequence in wash supervisor''s iPad or through other means like washing prioritization board / communication from JC to wash area (in case of no e-CRB), and in case there are 2 or more vehicles with same delivery time, EM & waiting Guest vehicle is prioritized.
3) Check for availability /usage of the washing materials. The Condition of Cloth used for washing has to be good.
5) Check existence of Quality Gate 3 inspector with clear R&R, Washing Checklist availability & Usage including QG#3 checkpoints with rejections
6) Service Manager Review mechanism of all Quality Gate 3 concerns & proofs (Action plan)',
    '1) The SWP should carry the following information
- Steps / Sequence of operations [What/When]
- Manpower details [Who]
- Tools used
- Washing training video is an effective tool to train staff on the washing
2) QG#3 Seal, Washing Check sheet, Q Talk Card, VOC shared proof, Daily discussion by Supervisor proof (register), Action plan based on analysis',
    '1) GS SOP Washing (Swayam Portal)
2) TSM FIR Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ046',
    'v1-DQ046-005',
    'Operation [Service]',
    'Washing',
    'Does Dealer ensure below Washing related standards?',
    'Operation [Service]',
    'Washing',
    'Quality Gate 3 is implemented with timely review & actions.',
    'Does Dealer ensure below Washing related standards?',
    'Direct',
    '3S',
    'Quality Gate 3 is implemented with timely review & actions.',
    '* Ensure High quality washing with in the set cycle time

* Quality Gate 3 rejection data analysis will ensure gap identification, Countermeasure and Manpower development',
    '1) Check for the SOP availability and observe the process to confirm if SOP is followed and work completed with in set cycle time
2) Vehicles must be prioritized for washing based on the sequence in wash supervisor''s iPad or through other means like washing prioritization board / communication from JC to wash area (in case of no e-CRB), and in case there are 2 or more vehicles with same delivery time, EM & waiting Guest vehicle is prioritized.
3) Check for availability /usage of the washing materials. The Condition of Cloth used for washing has to be good.
5) Check existence of Quality Gate 3 inspector with clear R&R, Washing Checklist availability & Usage including QG#3 checkpoints with rejections
6) Service Manager Review mechanism of all Quality Gate 3 concerns & proofs (Action plan)',
    '1) The SWP should carry the following information
- Steps / Sequence of operations [What/When]
- Manpower details [Who]
- Tools used
- Washing training video is an effective tool to train staff on the washing
2) QG#3 Seal, Washing Check sheet, Q Talk Card, VOC shared proof, Daily discussion by Supervisor proof (register), Action plan based on analysis',
    '1) GS SOP Washing (Swayam Portal)
2) TSM FIR Module (Swayam Portal)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ047',
    'v1-DQ047-001',
    'Safety & Environment',
    'Workshop',
    'Does dealer ensure compliance and follows regulations in handling hazardous material and waste water treatment?',
    'Safety & Environment',
    'Workshop',
    'Appropriate Hazard & waste water treatment (ETP',
    'Does dealer ensure compliance and follows regulations in handling hazardous material and waste water treatment?',
    'Indirect',
    '3S',
    'Appropriate Hazard & waste water treatment (ETP',
    '*To prevent contamination of environment and appropriate management of hazardous waste',
    '1) Check how the hazardous waste are sorted and stored (Keep away from sources of fire hazards)
2) Availability of written agreement with licensed waste management vendor
3) Check the availability of working ETP
4) HFC/CFC recovery and recycling system in operation',
    '1) Agreement with licensed waste management vendor
2) ETP in working condition and Reuse of treated water 
3) HFC/CFC recovery & recycling system record',
    '1) DIVA guiedline (ETP and Compliance standards)',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ047',
    'v1-DQ047-002',
    'Safety & Environment',
    'Workshop',
    'Does dealer ensure compliance and follows regulations in handling hazardous material and waste water treatment?',
    'Safety & Environment',
    'Workshop',
    'Appropriate A/C refrigerant recovery and recycling',
    'Does dealer ensure compliance and follows regulations in handling hazardous material and waste water treatment?',
    'Indirect',
    '3S',
    'Appropriate A/C refrigerant recovery and recycling',
    '*To prevent contamination of environment and appropriate management of hazardous waste',
    '1) Check how the hazardous waste are sorted and stored (Keep away from sources of fire hazards)
2) Availability of written agreement with licensed waste management vendor
3) Check the availability of working ETP
4) HFC/CFC recovery and recycling system in operation',
    '1) Agreement with licensed waste management vendor
2) ETP in working condition and Reuse of treated water 
3) HFC/CFC recovery & recycling system record',
    '1) DIVA guiedline (ETP and Compliance standards)',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ048',
    'v1-DQ048-001',
    'Facility',
    'Service Parking',
    'Does the dealer has adequate number of parking bays in service as per the DIVA standard for the following purpose?',
    'Facility',
    'Service Parking',
    'Service Shop Guests'' vehicle parking.',
    'Does the dealer has adequate number of parking bays in service as per the DIVA standard for the following purpose?',
    'Indirect',
    '3S',
    'Service Shop Guests'' vehicle parking.',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view. (as per approved drawings)

* Signages to identify & guide the  customers towards parking bays

* Security guiding the customer for right parking bay',
    '1) Check the number of vehicle parking availability, as per TKM approved plan 
2) Customer parking bay size must be 3m*5m, and must be clearly marked
3) Check that parking display signages available and clearly visible to guest 
4) The bays should not be marked in front of fire Hydrant access point and safe assembly points (fire hydrant system must not be blocked by parked vehicles)
5) Check no vehicles are parked other than designated parking spaces and not obstructing the work or movement (driveway).',
    '1) Check the facility drawing approved by DD & ensure no modifications in parking bays is done
2) If the available number of parking (as per TKM approved plan) is not sufficient to handle the current requirement (check during peak hour of showroom walk-ins), alternate arrangement to be made by the dealers (valet parking, additional bays)
3) Security must assist the guest during the parking',
    '1) DIVA guideline (Service Parkings)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ048',
    'v1-DQ048-002',
    'Facility',
    'Service Parking',
    'Does the dealer has adequate number of parking bays in service as per the DIVA standard for the following purpose?',
    'Facility',
    'Service Parking',
    'Service vehicle parking.',
    'Does the dealer has adequate number of parking bays in service as per the DIVA standard for the following purpose?',
    'Indirect',
    '3S',
    'Service vehicle parking.',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view. (as per approved drawings)

* Signages to identify & guide the  customers towards parking bays

* Security guiding the customer for right parking bay',
    '1) Check the number of vehicle parking availability, as per TKM approved plan 
2) Customer parking bay size must be 3m*5m, and must be clearly marked
3) Check that parking display signages available and clearly visible to guest 
4) The bays should not be marked in front of fire Hydrant access point and safe assembly points (fire hydrant system must not be blocked by parked vehicles)
5) Check no vehicles are parked other than designated parking spaces and not obstructing the work or movement (driveway).',
    '1) Check the facility drawing approved by DD & ensure no modifications in parking bays is done
2) If the available number of parking (as per TKM approved plan) is not sufficient to handle the current requirement (check during peak hour of showroom walk-ins), alternate arrangement to be made by the dealers (valet parking, additional bays)
3) Security must assist the guest during the parking',
    '1) DIVA guideline (Service Parkings)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ048',
    'v1-DQ048-003',
    'Facility',
    'Service Parking',
    'Does the dealer has adequate number of parking bays in service as per the DIVA standard for the following purpose?',
    'Facility',
    'Service Parking',
    'All Parking Bays have Name Boards & are Clearly Visible',
    'Does the dealer has adequate number of parking bays in service as per the DIVA standard for the following purpose?',
    'Indirect',
    '3S',
    'All Parking Bays have Name Boards & are Clearly Visible',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view. (as per approved drawings)

* Signages to identify & guide the  customers towards parking bays

* Security guiding the customer for right parking bay',
    '1) Check the number of vehicle parking availability, as per TKM approved plan 
2) Customer parking bay size must be 3m*5m, and must be clearly marked
3) Check that parking display signages available and clearly visible to guest 
4) The bays should not be marked in front of fire Hydrant access point and safe assembly points (fire hydrant system must not be blocked by parked vehicles)
5) Check no vehicles are parked other than designated parking spaces and not obstructing the work or movement (driveway).',
    '1) Check the facility drawing approved by DD & ensure no modifications in parking bays is done
2) If the available number of parking (as per TKM approved plan) is not sufficient to handle the current requirement (check during peak hour of showroom walk-ins), alternate arrangement to be made by the dealers (valet parking, additional bays)
3) Security must assist the guest during the parking',
    '1) DIVA guideline (Service Parkings)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ048',
    'v1-DQ048-004',
    'Facility',
    'Service Parking',
    'Does the dealer has adequate number of parking bays in service as per the DIVA standard for the following purpose?',
    'Facility',
    'Service Parking',
    'Adhere to all [TKM & Local administration] rules for parking bays',
    'Does the dealer has adequate number of parking bays in service as per the DIVA standard for the following purpose?',
    'Indirect',
    '3S',
    'Adhere to all [TKM & Local administration] rules for parking bays',
    '* All Toyota dealer workshops have to maintain basic requirements from facility point of view. (as per approved drawings)

* Signages to identify & guide the  customers towards parking bays

* Security guiding the customer for right parking bay',
    '1) Check the number of vehicle parking availability, as per TKM approved plan 
2) Customer parking bay size must be 3m*5m, and must be clearly marked
3) Check that parking display signages available and clearly visible to guest 
4) The bays should not be marked in front of fire Hydrant access point and safe assembly points (fire hydrant system must not be blocked by parked vehicles)
5) Check no vehicles are parked other than designated parking spaces and not obstructing the work or movement (driveway).',
    '1) Check the facility drawing approved by DD & ensure no modifications in parking bays is done
2) If the available number of parking (as per TKM approved plan) is not sufficient to handle the current requirement (check during peak hour of showroom walk-ins), alternate arrangement to be made by the dealers (valet parking, additional bays)
3) Security must assist the guest during the parking',
    '1) DIVA guideline (Service Parkings)',
    false,
    '["Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ049',
    'v1-DQ049-001',
    'Facility',
    'Stock Yard',
    'Dealer  maintain the new car stock yard as per the TKM guideline?',
    'Facility',
    'Stock Yard',
    'Stock yard neatness and marking as per standard',
    'Dealer  maintain the new car stock yard as per the TKM guideline?',
    'Indirect',
    '3S',
    'Stock yard neatness and marking as per standard',
    '*Ensures right availability of new car and delivery to guest as per his convenience',
    'Check the following :
1) Stock yard must be paved, clean and well lit (natural light preferably).
2) Stock yard and surrounding must be free from any hazardous materials and water logging.
3) The parking bays should be 3mt* X 5 mt (2.5 mts for small vehicles) and should be marked.
4) The parking bays must have wheel stoppers (at rear).
5) The stockyard drive ways should be at least 4 mts wide.
6) Wiper blades must be lifted & Battery terminal (-ve) must be disconnected.
7) Keys of the stock cars must be secured with stock yard in-charge and a log to maintained when the key is handed over to staff.',
    '1) Refer TDS (Transit, Display & Stock) guidebook for details
2) Stock vehicles must not be driven or operated by Guest.',
    '1) TDS (Transit, Display & Stock) guidebook',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ049',
    'v1-DQ049-002',
    'Facility',
    'Stock Yard',
    'Dealer  maintain the new car stock yard as per the TKM guideline?',
    'Facility',
    'Stock Yard',
    'Stock vehicles are stored with wiper blades lifted & battery terminal (-ve disconnected)',
    'Dealer  maintain the new car stock yard as per the TKM guideline?',
    'Indirect',
    '3S',
    'Stock vehicles are stored with wiper blades lifted & battery terminal (-ve disconnected)',
    '*Ensures right availability of new car and delivery to guest as per his convenience',
    'Check the following :
1) Stock yard must be paved, clean and well lit (natural light preferably).
2) Stock yard and surrounding must be free from any hazardous materials and water logging.
3) The parking bays should be 3mt* X 5 mt (2.5 mts for small vehicles) and should be marked.
4) The parking bays must have wheel stoppers (at rear).
5) The stockyard drive ways should be at least 4 mts wide.
6) Wiper blades must be lifted & Battery terminal (-ve) must be disconnected.
7) Keys of the stock cars must be secured with stock yard in-charge and a log to maintained when the key is handed over to staff.',
    '1) Refer TDS (Transit, Display & Stock) guidebook for details
2) Stock vehicles must not be driven or operated by Guest.',
    '1) TDS (Transit, Display & Stock) guidebook',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ049',
    'v1-DQ049-003',
    'Facility',
    'Stock Yard',
    'Dealer  maintain the new car stock yard as per the TKM guideline?',
    'Facility',
    'Stock Yard',
    'Stock vehicles keys are properly secured and managed by stock yard in-charge',
    'Dealer  maintain the new car stock yard as per the TKM guideline?',
    'Indirect',
    '3S',
    'Stock vehicles keys are properly secured and managed by stock yard in-charge',
    '*Ensures right availability of new car and delivery to guest as per his convenience',
    'Check the following :
1) Stock yard must be paved, clean and well lit (natural light preferably).
2) Stock yard and surrounding must be free from any hazardous materials and water logging.
3) The parking bays should be 3mt* X 5 mt (2.5 mts for small vehicles) and should be marked.
4) The parking bays must have wheel stoppers (at rear).
5) The stockyard drive ways should be at least 4 mts wide.
6) Wiper blades must be lifted & Battery terminal (-ve) must be disconnected.
7) Keys of the stock cars must be secured with stock yard in-charge and a log to maintained when the key is handed over to staff.',
    '1) Refer TDS (Transit, Display & Stock) guidebook for details
2) Stock vehicles must not be driven or operated by Guest.',
    '1) TDS (Transit, Display & Stock) guidebook',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ050',
    'v1-DQ050-001',
    'Operation [Sales]',
    'DCAC',
    '[Digital Lead Management]
Does dealer staff ensures immediate contact for New car digital leads and the necessary assistance is provided to customer?',
    'Operation [Sales]',
    'DCAC',
    'Dedicated PIC / Tele caller assigned and monitors the leads contact time.',
    '[Digital Lead Management]
Does dealer staff ensures immediate contact for New car digital leads and the necessary assistance is provided to customer?',
    'Direct',
    '3S',
    'Dedicated PIC / Tele caller assigned and monitors the leads contact time.',
    '*Ensures the convenience and give appropriate support to guest in deciding the vehicles.

*Ensures the capturing of business potential',
    '1) Check Tele caller or a dedicated PIC assigned to contact & qualify the digital leads 
2) Leads are contacted with in 10 mins from the time of receiving (Check KPI), during working Hours
3) Qualified leads are assigned to GEM Sales by tele caller after confirming GEM availability through rooster / WhatsApp group
4) GEM Sales to conttact the leads / Enquiry shared through iCROP within 10 ~ 15 minutes on Receiving
5) No of attempts made by Telecaller before dropping is 5 Attempta
6) Enquiry are followed by GEM-sales (at least 7 times) till the its converted to booking / dropped
7) Status of leads assigned to DCAC are reviewed by DCAC manager & Sales Manager jointly everyday / Weekly / Defined Periodicity
8) Status of the enquiries assigned to GEM-Sales is reviewed by SM daily and the reasons for dropped leads is validated',
    '1) Check Status of digital leads in ELMS
2) Sample check of leads (minimum 5 leads) in GEM sales i-crop ID to know the lead-time for contact the guest

Note : ELMS : Enhanced Lead Management System',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ050',
    'v1-DQ050-002',
    'Operation [Sales]',
    'DCAC',
    '[Digital Lead Management]
Does dealer staff ensures immediate contact for New car digital leads and the necessary assistance is provided to customer?',
    'Operation [Sales]',
    'DCAC',
    'Qualitfied leads assigned to GEM Sales as per the rooster through Whatsapp group.',
    '[Digital Lead Management]
Does dealer staff ensures immediate contact for New car digital leads and the necessary assistance is provided to customer?',
    'Direct',
    '3S',
    'Qualitfied leads assigned to GEM Sales as per the rooster through Whatsapp group.',
    '*Ensures the convenience and give appropriate support to guest in deciding the vehicles.

*Ensures the capturing of business potential',
    '1) Check Tele caller or a dedicated PIC assigned to contact & qualify the digital leads 
2) Leads are contacted with in 10 mins from the time of receiving (Check KPI), during working Hours
3) Qualified leads are assigned to GEM Sales by tele caller after confirming GEM availability through rooster / WhatsApp group
4) GEM Sales to conttact the leads / Enquiry shared through iCROP within 10 ~ 15 minutes on Receiving
5) No of attempts made by Telecaller before dropping is 5 Attempta
6) Enquiry are followed by GEM-sales (at least 7 times) till the its converted to booking / dropped
7) Status of leads assigned to DCAC are reviewed by DCAC manager & Sales Manager jointly everyday / Weekly / Defined Periodicity
8) Status of the enquiries assigned to GEM-Sales is reviewed by SM daily and the reasons for dropped leads is validated',
    '1) Check Status of digital leads in ELMS
2) Sample check of leads (minimum 5 leads) in GEM sales i-crop ID to know the lead-time for contact the guest

Note : ELMS : Enhanced Lead Management System',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ050',
    'v1-DQ050-003',
    'Operation [Sales]',
    'DCAC',
    '[Digital Lead Management]
Does dealer staff ensures immediate contact for New car digital leads and the necessary assistance is provided to customer?',
    'Operation [Sales]',
    'DCAC',
    'Status and review of leads by DCAC manager periodically and enquiries by Sales Manager',
    '[Digital Lead Management]
Does dealer staff ensures immediate contact for New car digital leads and the necessary assistance is provided to customer?',
    'Direct',
    '3S',
    'Status and review of leads by DCAC manager periodically and enquiries by Sales Manager',
    '*Ensures the convenience and give appropriate support to guest in deciding the vehicles.

*Ensures the capturing of business potential',
    '1) Check Tele caller or a dedicated PIC assigned to contact & qualify the digital leads 
2) Leads are contacted with in 10 mins from the time of receiving (Check KPI), during working Hours
3) Qualified leads are assigned to GEM Sales by tele caller after confirming GEM availability through rooster / WhatsApp group
4) GEM Sales to conttact the leads / Enquiry shared through iCROP within 10 ~ 15 minutes on Receiving
5) No of attempts made by Telecaller before dropping is 5 Attempta
6) Enquiry are followed by GEM-sales (at least 7 times) till the its converted to booking / dropped
7) Status of leads assigned to DCAC are reviewed by DCAC manager & Sales Manager jointly everyday / Weekly / Defined Periodicity
8) Status of the enquiries assigned to GEM-Sales is reviewed by SM daily and the reasons for dropped leads is validated',
    '1) Check Status of digital leads in ELMS
2) Sample check of leads (minimum 5 leads) in GEM sales i-crop ID to know the lead-time for contact the guest

Note : ELMS : Enhanced Lead Management System',
    '1) Seamless SOP Presentation (Lakshya Portal)',
    false,
    '["Sales"]'::jsonb,
    'active'
  ),
(
    'DQ051',
    'v1-DQ051-001',
    'Operation [Seamless]',
    'DCAC',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Operation [Seamless]',
    'DCAC',
    'MRS operation (DM + Calling is performed as per guideline in iCrop.)',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Direct',
    '3S',
    'MRS operation (DM + Calling is performed as per guideline in iCrop.)',
    '* To remind Guest about the appointment and thus improve the show-up rate

* To ensure the special order parts reserved / procured based on guest request are utilized for the right guest',
    '[MRS follow-up / Appointment Confirmation / No Show Follow-up]
1) DM Printing is performed on daily basis on all the roles / IDs to which DMs are assigned 
2) MRS calls are done on the same day the calls are generated in i-crop with out any delay.
3) Job planning is done accurately in SMB (appointment chip) for appointment booked guests.
4) Check if Repeat Repair, VOC & Potential Non-FIR are highlighted in Appointment Sheet.
5) SOP is available for N-1 day appointment confirmation and followed. 
6) No show follow-up is performed if the Guest does not turn up as per appointment time (with in 15 mins from planned appointment time)
[Repurchase Assitance / Value Chain Leads]
1) U-trust benefit is informed to exchange prospect UIO guests (>3 yrs. or  >60K KM) and the interest is captured & communicated to U-trust Procurement officer on N-1 day(email the list)
2) Identify the Potential lead for Value Chain (EW, Smiles+)
[Special Order Parts Handling]
1) Check if special order parts requirement is captured during appointment (SOPH form or excel file) & communicated to part warehouse on daily basis [Guest Info, Parts info, appointment date, order date, ETA / arrived date]
2) Status of special Order parts is received from parts warehouse on daily basis (Mail, SOPH forms), updated in visualization tool & communicated to guest incase of parts ETA update.',
    '1) Check activity condition setting to understand IDs to which DM is assigned
2) Following points are important from guest convenience point of view - 
- Reschedule non contacted calls to next day, send SMS / WhatsApp message..
- In case of ringing but no response - contact the guest after 4 hours or next day, for not responding cases, follow-up up to maximum 7 times on different days before closing the calls
- MRS calls must be closed in <60 day from the 1st call generated date unless guest has requested for call back beyond 60 days. In any case, the calls must be close with in 90 days to avoid suppression of future MRS call.',
    '1) MRS & Appointment SOP & Bulletins
2) Seamless SOP Presentation (Lakshya Portal)
3) TSM FIR Module (Swayam Portal)',
    false,
    '["Sales","Service & Parts","Used Car","Value Chain"]'::jsonb,
    'active'
  );

INSERT INTO audit_checklist_master (
  checklist_code,
  version,
  section,
  area,
  chapter,
  classification,
  location_aspect,
  evaluation_question,
  evaluation_parameter,
  guest_experience_impact,
  facility_type,
  question,
  purpose,
  checking_method,
  additional_info,
  sop_reference,
  evidence_required,
  applicable_departments,
  status
) VALUES
(
    'DQ051',
    'v1-DQ051-002',
    'Operation [Seamless]',
    'DCAC',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Operation [Seamless]',
    'DCAC',
    'The appointment confirmation & no-show follow-up is done by DCAC / appointment team and the status can be seen at a glance',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Direct',
    '3S',
    'The appointment confirmation & no-show follow-up is done by DCAC / appointment team and the status can be seen at a glance',
    '* To remind Guest about the appointment and thus improve the show-up rate

* To ensure the special order parts reserved / procured based on guest request are utilized for the right guest',
    '[MRS follow-up / Appointment Confirmation / No Show Follow-up]
1) DM Printing is performed on daily basis on all the roles / IDs to which DMs are assigned 
2) MRS calls are done on the same day the calls are generated in i-crop with out any delay.
3) Job planning is done accurately in SMB (appointment chip) for appointment booked guests.
4) Check if Repeat Repair, VOC & Potential Non-FIR are highlighted in Appointment Sheet.
5) SOP is available for N-1 day appointment confirmation and followed. 
6) No show follow-up is performed if the Guest does not turn up as per appointment time (with in 15 mins from planned appointment time)
[Repurchase Assitance / Value Chain Leads]
1) U-trust benefit is informed to exchange prospect UIO guests (>3 yrs. or  >60K KM) and the interest is captured & communicated to U-trust Procurement officer on N-1 day(email the list)
2) Identify the Potential lead for Value Chain (EW, Smiles+)
[Special Order Parts Handling]
1) Check if special order parts requirement is captured during appointment (SOPH form or excel file) & communicated to part warehouse on daily basis [Guest Info, Parts info, appointment date, order date, ETA / arrived date]
2) Status of special Order parts is received from parts warehouse on daily basis (Mail, SOPH forms), updated in visualization tool & communicated to guest incase of parts ETA update.',
    '1) Check activity condition setting to understand IDs to which DM is assigned
2) Following points are important from guest convenience point of view - 
- Reschedule non contacted calls to next day, send SMS / WhatsApp message..
- In case of ringing but no response - contact the guest after 4 hours or next day, for not responding cases, follow-up up to maximum 7 times on different days before closing the calls
- MRS calls must be closed in <60 day from the 1st call generated date unless guest has requested for call back beyond 60 days. In any case, the calls must be close with in 90 days to avoid suppression of future MRS call.',
    '1) MRS & Appointment SOP & Bulletins
2) Seamless SOP Presentation (Lakshya Portal)
3) TSM FIR Module (Swayam Portal)',
    false,
    '["Sales","Service & Parts","Used Car","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ051',
    'v1-DQ051-003',
    'Operation [Seamless]',
    'DCAC',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Operation [Seamless]',
    'DCAC',
    'Categorize Guests based on VOC, RR & Potential Non-FIR Guests in appointment list',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Direct',
    '3S',
    'Categorize Guests based on VOC, RR & Potential Non-FIR Guests in appointment list',
    '* To remind Guest about the appointment and thus improve the show-up rate

* To ensure the special order parts reserved / procured based on guest request are utilized for the right guest',
    '[MRS follow-up / Appointment Confirmation / No Show Follow-up]
1) DM Printing is performed on daily basis on all the roles / IDs to which DMs are assigned 
2) MRS calls are done on the same day the calls are generated in i-crop with out any delay.
3) Job planning is done accurately in SMB (appointment chip) for appointment booked guests.
4) Check if Repeat Repair, VOC & Potential Non-FIR are highlighted in Appointment Sheet.
5) SOP is available for N-1 day appointment confirmation and followed. 
6) No show follow-up is performed if the Guest does not turn up as per appointment time (with in 15 mins from planned appointment time)
[Repurchase Assitance / Value Chain Leads]
1) U-trust benefit is informed to exchange prospect UIO guests (>3 yrs. or  >60K KM) and the interest is captured & communicated to U-trust Procurement officer on N-1 day(email the list)
2) Identify the Potential lead for Value Chain (EW, Smiles+)
[Special Order Parts Handling]
1) Check if special order parts requirement is captured during appointment (SOPH form or excel file) & communicated to part warehouse on daily basis [Guest Info, Parts info, appointment date, order date, ETA / arrived date]
2) Status of special Order parts is received from parts warehouse on daily basis (Mail, SOPH forms), updated in visualization tool & communicated to guest incase of parts ETA update.',
    '1) Check activity condition setting to understand IDs to which DM is assigned
2) Following points are important from guest convenience point of view - 
- Reschedule non contacted calls to next day, send SMS / WhatsApp message..
- In case of ringing but no response - contact the guest after 4 hours or next day, for not responding cases, follow-up up to maximum 7 times on different days before closing the calls
- MRS calls must be closed in <60 day from the 1st call generated date unless guest has requested for call back beyond 60 days. In any case, the calls must be close with in 90 days to avoid suppression of future MRS call.',
    '1) MRS & Appointment SOP & Bulletins
2) Seamless SOP Presentation (Lakshya Portal)
3) TSM FIR Module (Swayam Portal)',
    false,
    '["Sales","Service & Parts","Used Car","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ051',
    'v1-DQ051-004',
    'Operation [Seamless]',
    'DCAC',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Operation [Seamless]',
    'DCAC',
    'Job planning is done SMB (appointment chip for appointment booked guests)',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Direct',
    '3S',
    'Job planning is done SMB (appointment chip for appointment booked guests)',
    '* To remind Guest about the appointment and thus improve the show-up rate

* To ensure the special order parts reserved / procured based on guest request are utilized for the right guest',
    '[MRS follow-up / Appointment Confirmation / No Show Follow-up]
1) DM Printing is performed on daily basis on all the roles / IDs to which DMs are assigned 
2) MRS calls are done on the same day the calls are generated in i-crop with out any delay.
3) Job planning is done accurately in SMB (appointment chip) for appointment booked guests.
4) Check if Repeat Repair, VOC & Potential Non-FIR are highlighted in Appointment Sheet.
5) SOP is available for N-1 day appointment confirmation and followed. 
6) No show follow-up is performed if the Guest does not turn up as per appointment time (with in 15 mins from planned appointment time)
[Repurchase Assitance / Value Chain Leads]
1) U-trust benefit is informed to exchange prospect UIO guests (>3 yrs. or  >60K KM) and the interest is captured & communicated to U-trust Procurement officer on N-1 day(email the list)
2) Identify the Potential lead for Value Chain (EW, Smiles+)
[Special Order Parts Handling]
1) Check if special order parts requirement is captured during appointment (SOPH form or excel file) & communicated to part warehouse on daily basis [Guest Info, Parts info, appointment date, order date, ETA / arrived date]
2) Status of special Order parts is received from parts warehouse on daily basis (Mail, SOPH forms), updated in visualization tool & communicated to guest incase of parts ETA update.',
    '1) Check activity condition setting to understand IDs to which DM is assigned
2) Following points are important from guest convenience point of view - 
- Reschedule non contacted calls to next day, send SMS / WhatsApp message..
- In case of ringing but no response - contact the guest after 4 hours or next day, for not responding cases, follow-up up to maximum 7 times on different days before closing the calls
- MRS calls must be closed in <60 day from the 1st call generated date unless guest has requested for call back beyond 60 days. In any case, the calls must be close with in 90 days to avoid suppression of future MRS call.',
    '1) MRS & Appointment SOP & Bulletins
2) Seamless SOP Presentation (Lakshya Portal)
3) TSM FIR Module (Swayam Portal)',
    false,
    '["Sales","Service & Parts","Used Car","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ051',
    'v1-DQ051-005',
    'Operation [Seamless]',
    'DCAC',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Operation [Seamless]',
    'DCAC',
    'U-trust benefit is informed to exchange eligible guests (>3 yrs. or >60K KM and the interest is captured & communicated to U-trust PIC.)',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Direct',
    '3S',
    'U-trust benefit is informed to exchange eligible guests (>3 yrs. or >60K KM and the interest is captured & communicated to U-trust PIC.)',
    '* To remind Guest about the appointment and thus improve the show-up rate

* To ensure the special order parts reserved / procured based on guest request are utilized for the right guest',
    '[MRS follow-up / Appointment Confirmation / No Show Follow-up]
1) DM Printing is performed on daily basis on all the roles / IDs to which DMs are assigned 
2) MRS calls are done on the same day the calls are generated in i-crop with out any delay.
3) Job planning is done accurately in SMB (appointment chip) for appointment booked guests.
4) Check if Repeat Repair, VOC & Potential Non-FIR are highlighted in Appointment Sheet.
5) SOP is available for N-1 day appointment confirmation and followed. 
6) No show follow-up is performed if the Guest does not turn up as per appointment time (with in 15 mins from planned appointment time)
[Repurchase Assitance / Value Chain Leads]
1) U-trust benefit is informed to exchange prospect UIO guests (>3 yrs. or  >60K KM) and the interest is captured & communicated to U-trust Procurement officer on N-1 day(email the list)
2) Identify the Potential lead for Value Chain (EW, Smiles+)
[Special Order Parts Handling]
1) Check if special order parts requirement is captured during appointment (SOPH form or excel file) & communicated to part warehouse on daily basis [Guest Info, Parts info, appointment date, order date, ETA / arrived date]
2) Status of special Order parts is received from parts warehouse on daily basis (Mail, SOPH forms), updated in visualization tool & communicated to guest incase of parts ETA update.',
    '1) Check activity condition setting to understand IDs to which DM is assigned
2) Following points are important from guest convenience point of view - 
- Reschedule non contacted calls to next day, send SMS / WhatsApp message..
- In case of ringing but no response - contact the guest after 4 hours or next day, for not responding cases, follow-up up to maximum 7 times on different days before closing the calls
- MRS calls must be closed in <60 day from the 1st call generated date unless guest has requested for call back beyond 60 days. In any case, the calls must be close with in 90 days to avoid suppression of future MRS call.',
    '1) MRS & Appointment SOP & Bulletins
2) Seamless SOP Presentation (Lakshya Portal)
3) TSM FIR Module (Swayam Portal)',
    false,
    '["Sales","Service & Parts","Used Car","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ051',
    'v1-DQ051-006',
    'Operation [Seamless]',
    'DCAC',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Operation [Seamless]',
    'DCAC',
    'MRS PIC identifies and generate potential lead for EW, Smiles+ and others',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Direct',
    '3S',
    'MRS PIC identifies and generate potential lead for EW, Smiles+ and others',
    '* To remind Guest about the appointment and thus improve the show-up rate

* To ensure the special order parts reserved / procured based on guest request are utilized for the right guest',
    '[MRS follow-up / Appointment Confirmation / No Show Follow-up]
1) DM Printing is performed on daily basis on all the roles / IDs to which DMs are assigned 
2) MRS calls are done on the same day the calls are generated in i-crop with out any delay.
3) Job planning is done accurately in SMB (appointment chip) for appointment booked guests.
4) Check if Repeat Repair, VOC & Potential Non-FIR are highlighted in Appointment Sheet.
5) SOP is available for N-1 day appointment confirmation and followed. 
6) No show follow-up is performed if the Guest does not turn up as per appointment time (with in 15 mins from planned appointment time)
[Repurchase Assitance / Value Chain Leads]
1) U-trust benefit is informed to exchange prospect UIO guests (>3 yrs. or  >60K KM) and the interest is captured & communicated to U-trust Procurement officer on N-1 day(email the list)
2) Identify the Potential lead for Value Chain (EW, Smiles+)
[Special Order Parts Handling]
1) Check if special order parts requirement is captured during appointment (SOPH form or excel file) & communicated to part warehouse on daily basis [Guest Info, Parts info, appointment date, order date, ETA / arrived date]
2) Status of special Order parts is received from parts warehouse on daily basis (Mail, SOPH forms), updated in visualization tool & communicated to guest incase of parts ETA update.',
    '1) Check activity condition setting to understand IDs to which DM is assigned
2) Following points are important from guest convenience point of view - 
- Reschedule non contacted calls to next day, send SMS / WhatsApp message..
- In case of ringing but no response - contact the guest after 4 hours or next day, for not responding cases, follow-up up to maximum 7 times on different days before closing the calls
- MRS calls must be closed in <60 day from the 1st call generated date unless guest has requested for call back beyond 60 days. In any case, the calls must be close with in 90 days to avoid suppression of future MRS call.',
    '1) MRS & Appointment SOP & Bulletins
2) Seamless SOP Presentation (Lakshya Portal)
3) TSM FIR Module (Swayam Portal)',
    false,
    '["Sales","Service & Parts","Used Car","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ051',
    'v1-DQ051-007',
    'Operation [Seamless]',
    'DCAC',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Operation [Seamless]',
    'DCAC',
    'Special Order Status Board in DCAC / Call Centre (PIC - MRS manager / leader',
    'Does dealer MRS staff performs the SOP as per TKM guideline?',
    'Direct',
    '3S',
    'Special Order Status Board in DCAC / Call Centre (PIC - MRS manager / leader',
    '* To remind Guest about the appointment and thus improve the show-up rate

* To ensure the special order parts reserved / procured based on guest request are utilized for the right guest',
    '[MRS follow-up / Appointment Confirmation / No Show Follow-up]
1) DM Printing is performed on daily basis on all the roles / IDs to which DMs are assigned 
2) MRS calls are done on the same day the calls are generated in i-crop with out any delay.
3) Job planning is done accurately in SMB (appointment chip) for appointment booked guests.
4) Check if Repeat Repair, VOC & Potential Non-FIR are highlighted in Appointment Sheet.
5) SOP is available for N-1 day appointment confirmation and followed. 
6) No show follow-up is performed if the Guest does not turn up as per appointment time (with in 15 mins from planned appointment time)
[Repurchase Assitance / Value Chain Leads]
1) U-trust benefit is informed to exchange prospect UIO guests (>3 yrs. or  >60K KM) and the interest is captured & communicated to U-trust Procurement officer on N-1 day(email the list)
2) Identify the Potential lead for Value Chain (EW, Smiles+)
[Special Order Parts Handling]
1) Check if special order parts requirement is captured during appointment (SOPH form or excel file) & communicated to part warehouse on daily basis [Guest Info, Parts info, appointment date, order date, ETA / arrived date]
2) Status of special Order parts is received from parts warehouse on daily basis (Mail, SOPH forms), updated in visualization tool & communicated to guest incase of parts ETA update.',
    '1) Check activity condition setting to understand IDs to which DM is assigned
2) Following points are important from guest convenience point of view - 
- Reschedule non contacted calls to next day, send SMS / WhatsApp message..
- In case of ringing but no response - contact the guest after 4 hours or next day, for not responding cases, follow-up up to maximum 7 times on different days before closing the calls
- MRS calls must be closed in <60 day from the 1st call generated date unless guest has requested for call back beyond 60 days. In any case, the calls must be close with in 90 days to avoid suppression of future MRS call.',
    '1) MRS & Appointment SOP & Bulletins
2) Seamless SOP Presentation (Lakshya Portal)
3) TSM FIR Module (Swayam Portal)',
    false,
    '["Sales","Service & Parts","Used Car","Value Chain"]'::jsonb,
    'active'
  ),
(
    'DQ052',
    'v1-DQ052-001',
    'Operation [Seamless]',
    'DCAC / Back Office',
    'Does dealer manages customer complaints as per the TKM guidelines?',
    'Operation [Seamless]',
    'DCAC / Back Office',
    'VOC (i-VOC & TKM VOC management at dealership through 7 step approach (GS, BP, Product - Grasping, Recovery, Recurrence prevention (refer annexure for 7 steps of complaint handling)',
    'Does dealer manages customer complaints as per the TKM guidelines?',
    'Direct',
    '3S',
    'VOC (i-VOC & TKM VOC management at dealership through 7 step approach (GS, BP, Product - Grasping, Recovery, Recurrence prevention (refer annexure for 7 steps of complaint handling)',
    '*Guest complaint details and handling results accurately recorded  in order to promptly share information within dealer

*All serious complaints visualized and reported to TKM in a timely manner in order to prevent further escalation

* Utilization of Guest voice for process correction & prevent reoccurrence',
    '1) Check Guest Handling Memos
2) Check the results of each of the 7 steps necessary for complaint handling recorded in the Guest Handling Memos & approved by management (Service Manager etc.)
3) Are general complaints and serious complaints correctly distinguished?
4) Are serious complaints reported to TKM within 24 business hours from the time they are received by the dealer? [Through FI/ Mail]
5) Check whether relevant KPIs (Process, Result) visualized & monitored in CTP/HTGE Obheya
6) Is RCA meeting held to discuss Non FIR cases, operational problems, and countermeasures developed, implemented & Sustained
7) Check the Visualization of VOCs related to Q1-Repair Quality (Repeat Repair & RR NVH), Q2-Vehicle not delivered on time & Q3-Time Taken for service not Reasonable',
    '1) Guest Handling memos.
2) Visualization of Serious Complaints (Ref. 9 types of serious complaints annex)
3) Field Information Report 
4) Records showing KPI monitoring & of RCA meetings
5) Check one RCA case other than Repair Quality and actual Countermeasure in Genba
6) Complaint Area: GS, BP, Product
- Complaint Tracker; Guest Retention report; Legal cases tracker
- Recovery - Action on Prioritized Complaints
- Recurrence prevention - Kaizen based on Complaints

Note : CV : Customer Voice, HTGE : Heart Touching Guest Experience',
    '1) VOC Handling SOP
2) Customer Voice Obheya guideline',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ052',
    'v1-DQ052-002',
    'Operation [Seamless]',
    'DCAC / Back Office',
    'Does dealer manages customer complaints as per the TKM guidelines?',
    'Operation [Seamless]',
    'DCAC / Back Office',
    'All complaints are handled according to SOP and recorded accurately while having clear distinction between general & serious complaints',
    'Does dealer manages customer complaints as per the TKM guidelines?',
    'Direct',
    '3S',
    'All complaints are handled according to SOP and recorded accurately while having clear distinction between general & serious complaints',
    '*Guest complaint details and handling results accurately recorded  in order to promptly share information within dealer

*All serious complaints visualized and reported to TKM in a timely manner in order to prevent further escalation

* Utilization of Guest voice for process correction & prevent reoccurrence',
    '1) Check Guest Handling Memos
2) Check the results of each of the 7 steps necessary for complaint handling recorded in the Guest Handling Memos & approved by management (Service Manager etc.)
3) Are general complaints and serious complaints correctly distinguished?
4) Are serious complaints reported to TKM within 24 business hours from the time they are received by the dealer? [Through FI/ Mail]
5) Check whether relevant KPIs (Process, Result) visualized & monitored in CTP/HTGE Obheya
6) Is RCA meeting held to discuss Non FIR cases, operational problems, and countermeasures developed, implemented & Sustained
7) Check the Visualization of VOCs related to Q1-Repair Quality (Repeat Repair & RR NVH), Q2-Vehicle not delivered on time & Q3-Time Taken for service not Reasonable',
    '1) Guest Handling memos.
2) Visualization of Serious Complaints (Ref. 9 types of serious complaints annex)
3) Field Information Report 
4) Records showing KPI monitoring & of RCA meetings
5) Check one RCA case other than Repair Quality and actual Countermeasure in Genba
6) Complaint Area: GS, BP, Product
- Complaint Tracker; Guest Retention report; Legal cases tracker
- Recovery - Action on Prioritized Complaints
- Recurrence prevention - Kaizen based on Complaints

Note : CV : Customer Voice, HTGE : Heart Touching Guest Experience',
    '1) VOC Handling SOP
2) Customer Voice Obheya guideline',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ052',
    'v1-DQ052-003',
    'Operation [Seamless]',
    'DCAC / Back Office',
    'Does dealer manages customer complaints as per the TKM guidelines?',
    'Operation [Seamless]',
    'DCAC / Back Office',
    'Root cause analysis [RCA] and countermeasure performed based on VOCs',
    'Does dealer manages customer complaints as per the TKM guidelines?',
    'Direct',
    '3S',
    'Root cause analysis [RCA] and countermeasure performed based on VOCs',
    '*Guest complaint details and handling results accurately recorded  in order to promptly share information within dealer

*All serious complaints visualized and reported to TKM in a timely manner in order to prevent further escalation

* Utilization of Guest voice for process correction & prevent reoccurrence',
    '1) Check Guest Handling Memos
2) Check the results of each of the 7 steps necessary for complaint handling recorded in the Guest Handling Memos & approved by management (Service Manager etc.)
3) Are general complaints and serious complaints correctly distinguished?
4) Are serious complaints reported to TKM within 24 business hours from the time they are received by the dealer? [Through FI/ Mail]
5) Check whether relevant KPIs (Process, Result) visualized & monitored in CTP/HTGE Obheya
6) Is RCA meeting held to discuss Non FIR cases, operational problems, and countermeasures developed, implemented & Sustained
7) Check the Visualization of VOCs related to Q1-Repair Quality (Repeat Repair & RR NVH), Q2-Vehicle not delivered on time & Q3-Time Taken for service not Reasonable',
    '1) Guest Handling memos.
2) Visualization of Serious Complaints (Ref. 9 types of serious complaints annex)
3) Field Information Report 
4) Records showing KPI monitoring & of RCA meetings
5) Check one RCA case other than Repair Quality and actual Countermeasure in Genba
6) Complaint Area: GS, BP, Product
- Complaint Tracker; Guest Retention report; Legal cases tracker
- Recovery - Action on Prioritized Complaints
- Recurrence prevention - Kaizen based on Complaints

Note : CV : Customer Voice, HTGE : Heart Touching Guest Experience',
    '1) VOC Handling SOP
2) Customer Voice Obheya guideline',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ052',
    'v1-DQ052-004',
    'Operation [Seamless]',
    'DCAC / Back Office',
    'Does dealer manages customer complaints as per the TKM guidelines?',
    'Operation [Seamless]',
    'DCAC / Back Office',
    'CV (Customer Voice /HTGE Obheya is updated with relevant KPIs (Process, Result)',
    'Does dealer manages customer complaints as per the TKM guidelines?',
    'Direct',
    '3S',
    'CV (Customer Voice /HTGE Obheya is updated with relevant KPIs (Process, Result)',
    '*Guest complaint details and handling results accurately recorded  in order to promptly share information within dealer

*All serious complaints visualized and reported to TKM in a timely manner in order to prevent further escalation

* Utilization of Guest voice for process correction & prevent reoccurrence',
    '1) Check Guest Handling Memos
2) Check the results of each of the 7 steps necessary for complaint handling recorded in the Guest Handling Memos & approved by management (Service Manager etc.)
3) Are general complaints and serious complaints correctly distinguished?
4) Are serious complaints reported to TKM within 24 business hours from the time they are received by the dealer? [Through FI/ Mail]
5) Check whether relevant KPIs (Process, Result) visualized & monitored in CTP/HTGE Obheya
6) Is RCA meeting held to discuss Non FIR cases, operational problems, and countermeasures developed, implemented & Sustained
7) Check the Visualization of VOCs related to Q1-Repair Quality (Repeat Repair & RR NVH), Q2-Vehicle not delivered on time & Q3-Time Taken for service not Reasonable',
    '1) Guest Handling memos.
2) Visualization of Serious Complaints (Ref. 9 types of serious complaints annex)
3) Field Information Report 
4) Records showing KPI monitoring & of RCA meetings
5) Check one RCA case other than Repair Quality and actual Countermeasure in Genba
6) Complaint Area: GS, BP, Product
- Complaint Tracker; Guest Retention report; Legal cases tracker
- Recovery - Action on Prioritized Complaints
- Recurrence prevention - Kaizen based on Complaints

Note : CV : Customer Voice, HTGE : Heart Touching Guest Experience',
    '1) VOC Handling SOP
2) Customer Voice Obheya guideline',
    false,
    '["Sales","Service & Parts","Used Car"]'::jsonb,
    'active'
  ),
(
    'DQ053',
    'v1-DQ053-001',
    'Safety & Environment',
    'Back office & Respective location',
    'Does dealer ensures and manages safety & environment activities as per distributor guidelines?',
    'Safety & Environment',
    'Back office & Respective location',
    'Established Safety & Environment organization (members from all depts of dealer with Trained Safety & Environment PIC.)',
    'Does dealer ensures and manages safety & environment activities as per distributor guidelines?',
    'Indirect',
    '3S',
    'Established Safety & Environment organization (members from all depts of dealer with Trained Safety & Environment PIC.)',
    '*Trained Emergency organization can prevent Loss of Human Life, Injury, property by effective response during emergency',
    '1) Check Safety & Environment Organization at dealer with actual role clarity.
2) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
3) Chart showing correct location of all fire extinguishers
4) Review Periodic Safety & Environment Audits records as advised by TKM. 
5) Review Meetings records involving Top Management [MoM] & action plan.
6) Grasps the Accident/ Incidents, analyze and take measures to prevent recurrence. Proof of sharing all Accident information timely with TKM.
7) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken. Interview staff for evidence of safety trainings involving all members of dealer
8) Check the availability of fire exit route and safe assembly area for guests & staff',
    '1) Updated Safety & Environment Organization Chart signed by DP/MD, with roles & responsibilities.
2) Staff training plan on Safety & Environment and records of conducted trainings
3) Audit Plan & reports; Proof of resolution of gaps identified with detail.
4) Meeting records, and attendance. Analysis and actions on  Accidents/ Incidents/ Near miss by dealer and sharing with TKM
5) Emergency evacuation mock drills',
    '1) SHE Obheya guideline & annexures',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ053',
    'v1-DQ053-002',
    'Safety & Environment',
    'Back office & Respective location',
    'Does dealer ensures and manages safety & environment activities as per distributor guidelines?',
    'Safety & Environment',
    'Back office & Respective location',
    'Periodic Safety and Environmental [Daily/Weekly/Monthly etc.] audits as per TKM guideline are conducted, records of audits maintained and issues identified are timely solved.',
    'Does dealer ensures and manages safety & environment activities as per distributor guidelines?',
    'Indirect',
    '3S',
    'Periodic Safety and Environmental [Daily/Weekly/Monthly etc.] audits as per TKM guideline are conducted, records of audits maintained and issues identified are timely solved.',
    '*Trained Emergency organization can prevent Loss of Human Life, Injury, property by effective response during emergency',
    '1) Check Safety & Environment Organization at dealer with actual role clarity.
2) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
3) Chart showing correct location of all fire extinguishers
4) Review Periodic Safety & Environment Audits records as advised by TKM. 
5) Review Meetings records involving Top Management [MoM] & action plan.
6) Grasps the Accident/ Incidents, analyze and take measures to prevent recurrence. Proof of sharing all Accident information timely with TKM.
7) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken. Interview staff for evidence of safety trainings involving all members of dealer
8) Check the availability of fire exit route and safe assembly area for guests & staff',
    '1) Updated Safety & Environment Organization Chart signed by DP/MD, with roles & responsibilities.
2) Staff training plan on Safety & Environment and records of conducted trainings
3) Audit Plan & reports; Proof of resolution of gaps identified with detail.
4) Meeting records, and attendance. Analysis and actions on  Accidents/ Incidents/ Near miss by dealer and sharing with TKM
5) Emergency evacuation mock drills',
    '1) SHE Obheya guideline & annexures',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ053',
    'v1-DQ053-003',
    'Safety & Environment',
    'Back office & Respective location',
    'Does dealer ensures and manages safety & environment activities as per distributor guidelines?',
    'Safety & Environment',
    'Back office & Respective location',
    'Monthly Safety & Environment meeting conducted with Top Management & safety organization with records maintained.',
    'Does dealer ensures and manages safety & environment activities as per distributor guidelines?',
    'Indirect',
    '3S',
    'Monthly Safety & Environment meeting conducted with Top Management & safety organization with records maintained.',
    '*Trained Emergency organization can prevent Loss of Human Life, Injury, property by effective response during emergency',
    '1) Check Safety & Environment Organization at dealer with actual role clarity.
2) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
3) Chart showing correct location of all fire extinguishers
4) Review Periodic Safety & Environment Audits records as advised by TKM. 
5) Review Meetings records involving Top Management [MoM] & action plan.
6) Grasps the Accident/ Incidents, analyze and take measures to prevent recurrence. Proof of sharing all Accident information timely with TKM.
7) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken. Interview staff for evidence of safety trainings involving all members of dealer
8) Check the availability of fire exit route and safe assembly area for guests & staff',
    '1) Updated Safety & Environment Organization Chart signed by DP/MD, with roles & responsibilities.
2) Staff training plan on Safety & Environment and records of conducted trainings
3) Audit Plan & reports; Proof of resolution of gaps identified with detail.
4) Meeting records, and attendance. Analysis and actions on  Accidents/ Incidents/ Near miss by dealer and sharing with TKM
5) Emergency evacuation mock drills',
    '1) SHE Obheya guideline & annexures',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ053',
    'v1-DQ053-004',
    'Safety & Environment',
    'Back office & Respective location',
    'Does dealer ensures and manages safety & environment activities as per distributor guidelines?',
    'Safety & Environment',
    'Back office & Respective location',
    'Emergency facilities are in operational condition and maintained',
    'Does dealer ensures and manages safety & environment activities as per distributor guidelines?',
    'Indirect',
    '3S',
    'Emergency facilities are in operational condition and maintained',
    '*Trained Emergency organization can prevent Loss of Human Life, Injury, property by effective response during emergency',
    '1) Check Safety & Environment Organization at dealer with actual role clarity.
2) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
3) Chart showing correct location of all fire extinguishers
4) Review Periodic Safety & Environment Audits records as advised by TKM. 
5) Review Meetings records involving Top Management [MoM] & action plan.
6) Grasps the Accident/ Incidents, analyze and take measures to prevent recurrence. Proof of sharing all Accident information timely with TKM.
7) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken. Interview staff for evidence of safety trainings involving all members of dealer
8) Check the availability of fire exit route and safe assembly area for guests & staff',
    '1) Updated Safety & Environment Organization Chart signed by DP/MD, with roles & responsibilities.
2) Staff training plan on Safety & Environment and records of conducted trainings
3) Audit Plan & reports; Proof of resolution of gaps identified with detail.
4) Meeting records, and attendance. Analysis and actions on  Accidents/ Incidents/ Near miss by dealer and sharing with TKM
5) Emergency evacuation mock drills',
    '1) SHE Obheya guideline & annexures',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ053',
    'v1-DQ053-005',
    'Safety & Environment',
    'Back office & Respective location',
    'Does dealer ensures and manages safety & environment activities as per distributor guidelines?',
    'Safety & Environment',
    'Back office & Respective location',
    'Emergency organization available and Trained in Emergency preparedness (Firefighting, First-aid, Rescue & Mock drill',
    'Does dealer ensures and manages safety & environment activities as per distributor guidelines?',
    'Indirect',
    '3S',
    'Emergency organization available and Trained in Emergency preparedness (Firefighting, First-aid, Rescue & Mock drill',
    '*Trained Emergency organization can prevent Loss of Human Life, Injury, property by effective response during emergency',
    '1) Check Safety & Environment Organization at dealer with actual role clarity.
2) Check fire fighting equipment availability in Front office, Near DG Set, Paint mixing room, Near Paint Booth, Value Yard, Chemicals/ Inflammable items storage area, and records of Third party check, functional test (as required)
3) Chart showing correct location of all fire extinguishers
4) Review Periodic Safety & Environment Audits records as advised by TKM. 
5) Review Meetings records involving Top Management [MoM] & action plan.
6) Grasps the Accident/ Incidents, analyze and take measures to prevent recurrence. Proof of sharing all Accident information timely with TKM.
7) Review last one year documents on Trainings/ Drills/ records and MoM of actions taken. Interview staff for evidence of safety trainings involving all members of dealer
8) Check the availability of fire exit route and safe assembly area for guests & staff',
    '1) Updated Safety & Environment Organization Chart signed by DP/MD, with roles & responsibilities.
2) Staff training plan on Safety & Environment and records of conducted trainings
3) Audit Plan & reports; Proof of resolution of gaps identified with detail.
4) Meeting records, and attendance. Analysis and actions on  Accidents/ Incidents/ Near miss by dealer and sharing with TKM
5) Emergency evacuation mock drills',
    '1) SHE Obheya guideline & annexures',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ054',
    'v1-DQ054-001',
    'Obheya',
    'Back Office / Meeting Room / Obheya Room',
    'Does Dealer Have DISHA HSC Obheya as per HanSaChu Guideline?',
    'Obheya',
    'Back Office / Meeting Room / Obheya Room',
    'Establish Obheya with clear roles and responsibility covering all HanSaChu KPIs',
    'Does Dealer Have DISHA HSC Obheya as per HanSaChu Guideline?',
    'Indirect',
    '3S',
    'Establish Obheya with clear roles and responsibility covering all HanSaChu KPIs',
    '*Effectivity manage overall operation and performance as a HanSaChu Organization

*Ensures the collective efforts to improve business and convenience of guests.',
    '1) Check availability of DISHA HSC Obheya and Organization chart (Involving HSC PIC''s)
2) Check following Process & result KPIs are monitor & Visualized In obheya
- Sales & Accessory : Nenkai, 1K Retention, Accessory Retails,
- Service & Parts : GUS/BPUS, SPO/SPR, Sales Lead, Used Car Lead, OTD, Repair Quality
- Used Car : UC Retail, UC Refurbish Lead
- Value Chain : EW, Smiles+, Finance, Insurance and Gloss Studio
- Seamless SOP : Lead generation (New Car, Used Car), 1K retention
- Guest Satisfaction : GX 360, NPS, VOC (TKM, IVOC)
3) Check the daily, weekly & monthly process sustenance check done & action plan is available.',
    '1) DISHA HSC Obheya
2) Process and Result KPI visualization as per DISHA HSC guidelines.
3) Small Group Activity Documents & Kaizen ideas',
    '1) DISHA HSC Obheya Annexure',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ054',
    'v1-DQ054-002',
    'Obheya',
    'Back Office / Meeting Room / Obheya Room',
    'Does Dealer Have DISHA HSC Obheya as per HanSaChu Guideline?',
    'Obheya',
    'Back Office / Meeting Room / Obheya Room',
    'Dealer monitor and visualize the Business KPI''s and Operation KPI''s in DISHA Obheya',
    'Does Dealer Have DISHA HSC Obheya as per HanSaChu Guideline?',
    'Indirect',
    '3S',
    'Dealer monitor and visualize the Business KPI''s and Operation KPI''s in DISHA Obheya',
    '*Effectivity manage overall operation and performance as a HanSaChu Organization

*Ensures the collective efforts to improve business and convenience of guests.',
    '1) Check availability of DISHA HSC Obheya and Organization chart (Involving HSC PIC''s)
2) Check following Process & result KPIs are monitor & Visualized In obheya
- Sales & Accessory : Nenkai, 1K Retention, Accessory Retails,
- Service & Parts : GUS/BPUS, SPO/SPR, Sales Lead, Used Car Lead, OTD, Repair Quality
- Used Car : UC Retail, UC Refurbish Lead
- Value Chain : EW, Smiles+, Finance, Insurance and Gloss Studio
- Seamless SOP : Lead generation (New Car, Used Car), 1K retention
- Guest Satisfaction : GX 360, NPS, VOC (TKM, IVOC)
3) Check the daily, weekly & monthly process sustenance check done & action plan is available.',
    '1) DISHA HSC Obheya
2) Process and Result KPI visualization as per DISHA HSC guidelines.
3) Small Group Activity Documents & Kaizen ideas',
    '1) DISHA HSC Obheya Annexure',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ054',
    'v1-DQ054-003',
    'Obheya',
    'Back Office / Meeting Room / Obheya Room',
    'Does Dealer Have DISHA HSC Obheya as per HanSaChu Guideline?',
    'Obheya',
    'Back Office / Meeting Room / Obheya Room',
    'DISHA Performance (Qualitative & Quantitative is reviewed by dealer management and root cause analysis & counter measure is initiated through SGA by genba staff.)',
    'Does Dealer Have DISHA HSC Obheya as per HanSaChu Guideline?',
    'Indirect',
    '3S',
    'DISHA Performance (Qualitative & Quantitative is reviewed by dealer management and root cause analysis & counter measure is initiated through SGA by genba staff.)',
    '*Effectivity manage overall operation and performance as a HanSaChu Organization

*Ensures the collective efforts to improve business and convenience of guests.',
    '1) Check availability of DISHA HSC Obheya and Organization chart (Involving HSC PIC''s)
2) Check following Process & result KPIs are monitor & Visualized In obheya
- Sales & Accessory : Nenkai, 1K Retention, Accessory Retails,
- Service & Parts : GUS/BPUS, SPO/SPR, Sales Lead, Used Car Lead, OTD, Repair Quality
- Used Car : UC Retail, UC Refurbish Lead
- Value Chain : EW, Smiles+, Finance, Insurance and Gloss Studio
- Seamless SOP : Lead generation (New Car, Used Car), 1K retention
- Guest Satisfaction : GX 360, NPS, VOC (TKM, IVOC)
3) Check the daily, weekly & monthly process sustenance check done & action plan is available.',
    '1) DISHA HSC Obheya
2) Process and Result KPI visualization as per DISHA HSC guidelines.
3) Small Group Activity Documents & Kaizen ideas',
    '1) DISHA HSC Obheya Annexure',
    false,
    '["Other"]'::jsonb,
    'active'
  ),
(
    'DQ055',
    'v1-DQ055-001',
    'Staff',
    'HR / Obheya',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Staff',
    'HR / Obheya',
    'Dealer has sufficient manpower in Sales, Service & Parts, Accessory, Value Chain and Used Car as per distributor guideline in each area.',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Indirect',
    '3S',
    'Dealer has sufficient manpower in Sales, Service & Parts, Accessory, Value Chain and Used Car as per distributor guideline in each area.',
    '*To Ensure effective and sufficient manpower availability to perform efficient operation & business.',
    '1) Check availability of organization of Sales, Service & Parts, Used Car, Accessory & Value Chain.
2) Check availability of DISHA HSC organization with clear roles & responsibilities
3) Check sufficient manpower available in each Areas
- GEM Sales : Based on SBU guidance
- GEM Service : 7 vehicles per day per GEM Service
- Procurement Officer : Efficiency 6.7 (All India) - Refer SBU wise efficiency from U-trust
- Used Car Sales Officer : Efficiency 7.8 (All India) - Refer SBU wise efficiency from U-trust
4) Check Motivation scheme to Staff [e.g.,. E-mail, Notice Board etc.]
5) Check actual document [Physical / Digital] for Training Materials & Calendar',
    '1) Dealer Organization Chart (Each Area)
2) DISHA HSC Organization Chart
3) Area wise Manpower Count and Training Status
4) Motivation Scheme
5) Training Calendar',
    '1) Dealer Organization Reference (As per SBU direction)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ055',
    'v1-DQ055-002',
    'Staff',
    'HR / Obheya',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Staff',
    'HR / Obheya',
    'Dealer has DISHA HSC PICs with clear roles & responsibilities (Concurrent or Dedicated',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Indirect',
    '3S',
    'Dealer has DISHA HSC PICs with clear roles & responsibilities (Concurrent or Dedicated',
    '*To Ensure effective and sufficient manpower availability to perform efficient operation & business.',
    '1) Check availability of organization of Sales, Service & Parts, Used Car, Accessory & Value Chain.
2) Check availability of DISHA HSC organization with clear roles & responsibilities
3) Check sufficient manpower available in each Areas
- GEM Sales : Based on SBU guidance
- GEM Service : 7 vehicles per day per GEM Service
- Procurement Officer : Efficiency 6.7 (All India) - Refer SBU wise efficiency from U-trust
- Used Car Sales Officer : Efficiency 7.8 (All India) - Refer SBU wise efficiency from U-trust
4) Check Motivation scheme to Staff [e.g.,. E-mail, Notice Board etc.]
5) Check actual document [Physical / Digital] for Training Materials & Calendar',
    '1) Dealer Organization Chart (Each Area)
2) DISHA HSC Organization Chart
3) Area wise Manpower Count and Training Status
4) Motivation Scheme
5) Training Calendar',
    '1) Dealer Organization Reference (As per SBU direction)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ055',
    'v1-DQ055-003',
    'Staff',
    'HR / Obheya',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Staff',
    'HR / Obheya',
    'All Manpower details to be available in Lakshya and Swayam Portal',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Indirect',
    '3S',
    'All Manpower details to be available in Lakshya and Swayam Portal',
    '*To Ensure effective and sufficient manpower availability to perform efficient operation & business.',
    '1) Check availability of organization of Sales, Service & Parts, Used Car, Accessory & Value Chain.
2) Check availability of DISHA HSC organization with clear roles & responsibilities
3) Check sufficient manpower available in each Areas
- GEM Sales : Based on SBU guidance
- GEM Service : 7 vehicles per day per GEM Service
- Procurement Officer : Efficiency 6.7 (All India) - Refer SBU wise efficiency from U-trust
- Used Car Sales Officer : Efficiency 7.8 (All India) - Refer SBU wise efficiency from U-trust
4) Check Motivation scheme to Staff [e.g.,. E-mail, Notice Board etc.]
5) Check actual document [Physical / Digital] for Training Materials & Calendar',
    '1) Dealer Organization Chart (Each Area)
2) DISHA HSC Organization Chart
3) Area wise Manpower Count and Training Status
4) Motivation Scheme
5) Training Calendar',
    '1) Dealer Organization Reference (As per SBU direction)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ055',
    'v1-DQ055-004',
    'Staff',
    'HR / Obheya',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Staff',
    'HR / Obheya',
    'Availability of alteast 1 Certified Instructor (GT, BP, SA, SP',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Indirect',
    '3S',
    'Availability of alteast 1 Certified Instructor (GT, BP, SA, SP',
    '*To Ensure effective and sufficient manpower availability to perform efficient operation & business.',
    '1) Check availability of organization of Sales, Service & Parts, Used Car, Accessory & Value Chain.
2) Check availability of DISHA HSC organization with clear roles & responsibilities
3) Check sufficient manpower available in each Areas
- GEM Sales : Based on SBU guidance
- GEM Service : 7 vehicles per day per GEM Service
- Procurement Officer : Efficiency 6.7 (All India) - Refer SBU wise efficiency from U-trust
- Used Car Sales Officer : Efficiency 7.8 (All India) - Refer SBU wise efficiency from U-trust
4) Check Motivation scheme to Staff [e.g.,. E-mail, Notice Board etc.]
5) Check actual document [Physical / Digital] for Training Materials & Calendar',
    '1) Dealer Organization Chart (Each Area)
2) DISHA HSC Organization Chart
3) Area wise Manpower Count and Training Status
4) Motivation Scheme
5) Training Calendar',
    '1) Dealer Organization Reference (As per SBU direction)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ055',
    'v1-DQ055-005',
    'Staff',
    'HR / Obheya',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Staff',
    'HR / Obheya',
    'Availability of atleast 1 Customer handling staff',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Indirect',
    '3S',
    'Availability of atleast 1 Customer handling staff',
    '*To Ensure effective and sufficient manpower availability to perform efficient operation & business.',
    '1) Check availability of organization of Sales, Service & Parts, Used Car, Accessory & Value Chain.
2) Check availability of DISHA HSC organization with clear roles & responsibilities
3) Check sufficient manpower available in each Areas
- GEM Sales : Based on SBU guidance
- GEM Service : 7 vehicles per day per GEM Service
- Procurement Officer : Efficiency 6.7 (All India) - Refer SBU wise efficiency from U-trust
- Used Car Sales Officer : Efficiency 7.8 (All India) - Refer SBU wise efficiency from U-trust
4) Check Motivation scheme to Staff [e.g.,. E-mail, Notice Board etc.]
5) Check actual document [Physical / Digital] for Training Materials & Calendar',
    '1) Dealer Organization Chart (Each Area)
2) DISHA HSC Organization Chart
3) Area wise Manpower Count and Training Status
4) Motivation Scheme
5) Training Calendar',
    '1) Dealer Organization Reference (As per SBU direction)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ055',
    'v1-DQ055-006',
    'Staff',
    'HR / Obheya',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Staff',
    'HR / Obheya',
    'Track the number graded manpower''s (Platinum, Gold, Silver, Ungraded in Used Car)',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Indirect',
    '3S',
    'Track the number graded manpower''s (Platinum, Gold, Silver, Ungraded in Used Car)',
    '*To Ensure effective and sufficient manpower availability to perform efficient operation & business.',
    '1) Check availability of organization of Sales, Service & Parts, Used Car, Accessory & Value Chain.
2) Check availability of DISHA HSC organization with clear roles & responsibilities
3) Check sufficient manpower available in each Areas
- GEM Sales : Based on SBU guidance
- GEM Service : 7 vehicles per day per GEM Service
- Procurement Officer : Efficiency 6.7 (All India) - Refer SBU wise efficiency from U-trust
- Used Car Sales Officer : Efficiency 7.8 (All India) - Refer SBU wise efficiency from U-trust
4) Check Motivation scheme to Staff [e.g.,. E-mail, Notice Board etc.]
5) Check actual document [Physical / Digital] for Training Materials & Calendar',
    '1) Dealer Organization Chart (Each Area)
2) DISHA HSC Organization Chart
3) Area wise Manpower Count and Training Status
4) Motivation Scheme
5) Training Calendar',
    '1) Dealer Organization Reference (As per SBU direction)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ055',
    'v1-DQ055-007',
    'Staff',
    'HR / Obheya',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Staff',
    'HR / Obheya',
    'Availability of Motivation scheme for all dealer staff based on performance in all areas.',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Indirect',
    '3S',
    'Availability of Motivation scheme for all dealer staff based on performance in all areas.',
    '*To Ensure effective and sufficient manpower availability to perform efficient operation & business.',
    '1) Check availability of organization of Sales, Service & Parts, Used Car, Accessory & Value Chain.
2) Check availability of DISHA HSC organization with clear roles & responsibilities
3) Check sufficient manpower available in each Areas
- GEM Sales : Based on SBU guidance
- GEM Service : 7 vehicles per day per GEM Service
- Procurement Officer : Efficiency 6.7 (All India) - Refer SBU wise efficiency from U-trust
- Used Car Sales Officer : Efficiency 7.8 (All India) - Refer SBU wise efficiency from U-trust
4) Check Motivation scheme to Staff [e.g.,. E-mail, Notice Board etc.]
5) Check actual document [Physical / Digital] for Training Materials & Calendar',
    '1) Dealer Organization Chart (Each Area)
2) DISHA HSC Organization Chart
3) Area wise Manpower Count and Training Status
4) Motivation Scheme
5) Training Calendar',
    '1) Dealer Organization Reference (As per SBU direction)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  ),
(
    'DQ055',
    'v1-DQ055-008',
    'Staff',
    'HR / Obheya',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Staff',
    'HR / Obheya',
    'Availability of Monthly Training Calendar for each function dealer staff (HanSaChu',
    'Does Dealer Have organization as per HanSaChu Guideline (including DISHA PICs)?',
    'Indirect',
    '3S',
    'Availability of Monthly Training Calendar for each function dealer staff (HanSaChu',
    '*To Ensure effective and sufficient manpower availability to perform efficient operation & business.',
    '1) Check availability of organization of Sales, Service & Parts, Used Car, Accessory & Value Chain.
2) Check availability of DISHA HSC organization with clear roles & responsibilities
3) Check sufficient manpower available in each Areas
- GEM Sales : Based on SBU guidance
- GEM Service : 7 vehicles per day per GEM Service
- Procurement Officer : Efficiency 6.7 (All India) - Refer SBU wise efficiency from U-trust
- Used Car Sales Officer : Efficiency 7.8 (All India) - Refer SBU wise efficiency from U-trust
4) Check Motivation scheme to Staff [e.g.,. E-mail, Notice Board etc.]
5) Check actual document [Physical / Digital] for Training Materials & Calendar',
    '1) Dealer Organization Chart (Each Area)
2) DISHA HSC Organization Chart
3) Area wise Manpower Count and Training Status
4) Motivation Scheme
5) Training Calendar',
    '1) Dealer Organization Reference (As per SBU direction)',
    false,
    '["Sales","Service & Parts"]'::jsonb,
    'active'
  );

COMMIT;
