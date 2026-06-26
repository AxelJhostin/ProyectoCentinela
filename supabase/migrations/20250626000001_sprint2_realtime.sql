-- Realtime para actualizar Home cuando hay alertas nuevas
ALTER PUBLICATION supabase_realtime ADD TABLE public.alertas_desaparecidos;
