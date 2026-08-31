# Zyklusvorhersagen

Zyklusdaten werden lokal gespeichert und niemals über den Remote-Lebensmittelservice synchronisiert. Die Vorhersage-Engine nutzt Periodenstarts, den Median gültiger Intervalle (21–45 Tage), eine robuste Median/MAD-Ausreißerbehandlung und die durchschnittliche Blutungsdauer. Bei fehlender Historie werden die im Profil hinterlegten 28/5-Tage-Defaults verwendet.

Die Engine liefert nächste Periode, fruchtbares Fenster, Zyklustag, Konfidenz und eine maschinenlesbare Begründung. Konfidenz ist eine Unsicherheitsanzeige, keine medizinische Diagnose. Unregelmäßige oder fehlende Einträge senken die Konfidenz; die UI kennzeichnet Prognosen als Schätzung und darf keine Verhütungs- oder Therapieentscheidung daraus ableiten.

Symptome, Stimmung, Schmerz, Energie und Schlafqualität werden als Tageslogs mit lokaler Tagesgrenze gespeichert. Einträge können korrigiert oder gelöscht werden, ohne historische Rohdaten zu verändern. Der Kalender markiert Perioden und Check-in-Tage; Historienkarten zeigen Median und Streuung. Schmerz, Energie und Schlafqualität werden auf 0–10 validiert.

Prognosen bleiben Schätzungen mit Konfidenz und maschinenlesbarer Begründung, keine medizinische Diagnose. Der optionale Health-Connect-Import von Menstruationsdaten ist im aktuellen Android-Arbeitspaket noch nicht aktiviert.
