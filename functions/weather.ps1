# Affiche la météo sur trois jours à Massy
function get_meteo {
    (Invoke-WebRequest -useb 'http://wttr.in/Massy?mAFq&lang=fr').Content
}