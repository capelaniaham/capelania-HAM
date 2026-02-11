
-- SCHEMA INDEPENDENTE V4.0
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

-- SEED: Criar Administrador Inicial (Senha: Admin1)
-- O hash abaixo é o SHA-256 de 'Admin1'
INSERT INTO users (id, name, email, password, role)
VALUES (
    gen_random_uuid(), 
    'Admin1', 
    'john.lima@ham.org.br', 
    'e96e95c1871f76f45517172782b6c166d357288764268e37a77e5d8479e00085', 
    'ADMIN'
) ON CONFLICT (email) DO NOTHING;

CREATE TABLE IF NOT EXISTS app_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mural_text TEXT,
    header_line1 TEXT,
    header_line2 TEXT,
    header_line3 TEXT,
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
    app_logo_url TEXT,
    report_logo_url TEXT,
    last_modified_by TEXT,
    last_modified_at BIGINT,
    updated_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

CREATE TABLE IF NOT EXISTS bible_studies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    unit TEXT,
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
    unit TEXT,
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
    staff_id BIGINT,
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

CREATE TABLE IF NOT EXISTS small_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    unit TEXT,
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
    unit TEXT,
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

CREATE TABLE IF NOT EXISTS pro_sectors (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    unit TEXT NOT NULL,
    active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS pro_staff (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    sector_id TEXT REFERENCES pro_sectors(id) ON UPDATE CASCADE,
    unit TEXT NOT NULL,
    whatsapp TEXT,
    active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS pro_groups (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    current_leader TEXT,
    leader_phone TEXT,
    sector_id TEXT REFERENCES pro_sectors(id),
    unit TEXT NOT NULL,
    active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS pro_group_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id TEXT REFERENCES pro_groups(id) ON DELETE CASCADE,
    sector_id TEXT REFERENCES pro_sectors(id) ON DELETE CASCADE,
    unit TEXT NOT NULL,
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

CREATE TABLE IF NOT EXISTS pro_group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id TEXT REFERENCES pro_groups(id) ON DELETE CASCADE,
    staff_id TEXT REFERENCES pro_staff(id) ON DELETE CASCADE,
    joined_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

CREATE TABLE IF NOT EXISTS visit_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pg_name TEXT NOT NULL,
    leader_name TEXT NOT NULL,
    leader_phone TEXT,
    unit TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'pending',
    request_notes TEXT,
    preferred_chaplain_id TEXT,
    assigned_chaplain_id TEXT,
    chaplain_response TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000),
    updated_at BIGINT DEFAULT (extract(epoch from now()) * 1000)
);

-- RLS POLICIES
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON users FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON app_config FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE bible_studies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON bible_studies FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE bible_classes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON bible_classes FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE bible_class_attendees ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON bible_class_attendees FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE small_groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON small_groups FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE staff_visits ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON staff_visits FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE pro_sectors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON pro_sectors FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE pro_staff ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON pro_staff FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE pro_groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON pro_groups FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE pro_group_locations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON pro_group_locations FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE pro_group_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON pro_group_members FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE visit_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso Total" ON visit_requests FOR ALL USING (true) WITH CHECK (true);
