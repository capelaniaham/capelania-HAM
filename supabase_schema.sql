
-- SCHEMA EXCLUSIVO HOSPITAL ADVENTISTA DE MANAUS (HAM) V5.0
-- Este script deve ser rodado no SQL Editor do seu Supabase

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'CHAPLAIN',
    profile_pic TEXT,
    updated_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

-- SEED: Administrador John Lima (Manaus)
INSERT INTO users (id, name, email, password, role)
VALUES (
    gen_random_uuid(), 
    'John Lima', 
    'john.lima@ham.org.br', 
    'e96e95c1871f76f45517172782b6c166d357288764268e37a77e5d8479e00085', -- Admin1
    'ADMIN'
) ON CONFLICT (email) DO NOTHING;

CREATE TABLE IF NOT EXISTS app_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mural_text TEXT DEFAULT 'Bem-vindo ao Sistema de Capelania HAM',
    header_line1 TEXT DEFAULT 'Hospital Adventista de Manaus',
    header_line2 TEXT DEFAULT 'Departamento de Capelania',
    header_line3 TEXT DEFAULT 'Assistência Espiritual',
    font_size1 INTEGER DEFAULT 24,
    font_size2 INTEGER DEFAULT 18,
    font_size3 INTEGER DEFAULT 12,
    report_logo_width INTEGER DEFAULT 150,
    report_logo_x INTEGER DEFAULT 40,
    report_logo_y INTEGER DEFAULT 20,
    header_line1_x INTEGER DEFAULT 200,
    header_line1_y INTEGER DEFAULT 30,
    header_line2_x INTEGER DEFAULT 200,
    header_line2_y INTEGER DEFAULT 65,
    header_line3_x INTEGER DEFAULT 200,
    header_line3_y INTEGER DEFAULT 90,
    header_padding_top INTEGER DEFAULT 30,
    header_text_align TEXT DEFAULT 'left',
    primary_color TEXT DEFAULT '#005a9c',
    updated_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

CREATE TABLE IF NOT EXISTS bible_studies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    unit TEXT DEFAULT 'HAM',
    sector TEXT,
    name TEXT,
    whatsapp TEXT,
    status TEXT,
    participant_type TEXT,
    guide TEXT,
    lesson TEXT,
    observations TEXT,
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000),
    updated_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

CREATE TABLE IF NOT EXISTS bible_classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    unit TEXT DEFAULT 'HAM',
    sector TEXT,
    status TEXT,
    participant_type TEXT,
    guide TEXT,
    lesson TEXT,
    observations TEXT,
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000),
    updated_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

CREATE TABLE IF NOT EXISTS bible_class_attendees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID REFERENCES bible_classes(id) ON DELETE CASCADE,
    student_name TEXT,
    staff_id TEXT,
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

CREATE TABLE IF NOT EXISTS small_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    unit TEXT DEFAULT 'HAM',
    sector TEXT,
    group_name TEXT,
    leader TEXT,
    leader_phone TEXT,
    shift TEXT,
    participants_count INTEGER,
    observations TEXT,
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000),
    updated_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

CREATE TABLE IF NOT EXISTS staff_visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    unit TEXT DEFAULT 'HAM',
    sector TEXT,
    reason TEXT,
    staff_name TEXT,
    requires_return BOOLEAN DEFAULT false,
    return_date TIMESTAMP WITH TIME ZONE,
    return_completed BOOLEAN DEFAULT false,
    observations TEXT,
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000),
    updated_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

CREATE TABLE IF NOT EXISTS pro_sectors (id TEXT PRIMARY KEY, name TEXT NOT NULL, unit TEXT DEFAULT 'HAM', active BOOLEAN DEFAULT true);
CREATE TABLE IF NOT EXISTS pro_staff (id TEXT PRIMARY KEY, name TEXT NOT NULL, sector_id TEXT REFERENCES pro_sectors(id), unit TEXT DEFAULT 'HAM', whatsapp TEXT, active BOOLEAN DEFAULT true);
CREATE TABLE IF NOT EXISTS pro_groups (id TEXT PRIMARY KEY, name TEXT NOT NULL, current_leader TEXT, leader_phone TEXT, unit TEXT DEFAULT 'HAM', active BOOLEAN DEFAULT true);
CREATE TABLE IF NOT EXISTS pro_group_locations (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), group_id TEXT REFERENCES pro_groups(id) ON DELETE CASCADE, sector_id TEXT REFERENCES pro_sectors(id) ON DELETE CASCADE, unit TEXT DEFAULT 'HAM');
CREATE TABLE IF NOT EXISTS pro_group_members (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), group_id TEXT REFERENCES pro_groups(id) ON DELETE CASCADE, staff_id TEXT REFERENCES pro_staff(id) ON DELETE CASCADE);
CREATE TABLE IF NOT EXISTS visit_requests (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), pg_name TEXT NOT NULL, leader_name TEXT NOT NULL, leader_phone TEXT, unit TEXT DEFAULT 'HAM', date TIMESTAMP WITH TIME ZONE, status TEXT DEFAULT 'pending', is_read BOOLEAN DEFAULT false);

-- ATIVAÇÃO DE RLS COM CORREÇÃO DE ERRO 42710 (POLÍTICA EXISTENTE)
DO $$ 
DECLARE 
    t text;
BEGIN
    FOR t IN (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public') 
    LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('DROP POLICY IF EXISTS "Acesso Total" ON %I', t);
        EXECUTE format('CREATE POLICY "Acesso Total" ON %I FOR ALL USING (true) WITH CHECK (true)', t);
    END LOOP;
END $$;
