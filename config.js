// Collegamento al database Supabase "giocate-app".
// La chiave "anon" è pubblica per natura: da sola non permette di leggere
// né modificare le giocate, serve anche il codice di accesso.
// NON inserire mai qui la chiave "service_role" / "secret".
window.GIOCATE_CONFIG = {
  url: "https://beerjityeundqdwlhzkp.supabase.co",
  key: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlZXJqaXR5ZXVuZHFkd2xoemtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTUyNDI2MDYsImV4cCI6MjExMDgxODYwNn0.TOdrvAbNDlKD0g6EjdHOlfRIuAgsjPjMWxTznt4bnBs"
};
