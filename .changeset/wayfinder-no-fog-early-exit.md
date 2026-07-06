---
"mattpocock-skills": patch
---

Restore **`wayfinder`**'s early exit when the frontier grilling turns up no fog.

The skill used to have a **Skipping The Decision Map** section: if the opening grilling surfaced no fog of war, there was no map to build, so it offered to skip straight to implementing. That clause was demoted to a parenthetical inside the Handoff section, then deleted as collateral when Handoff was removed — never an intentional cut.

It's back, co-located in **Chart the map** step 2 (Map the frontier), where the fog/no-fog outcome is actually determined: if breadth-first grilling surfaces no fog, tell the user and offer to skip the map, implementing directly instead. The offer — asking rather than auto-skipping — is preserved from the original.
