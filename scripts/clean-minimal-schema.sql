-- =====================================================
-- CLEAN MINIMAL SCHEMA - Only what's actually needed
-- =====================================================
-- This script creates a minimal, working schema for the Erigga platform

-- Step 1: Clean slate
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO anon;
GRANT ALL ON SCHEMA public TO authenticated;

-- Step 2: Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Users table (core user profiles)
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL CHECK (length(username) >= 3 AND length(username) <= 30),
    full_name TEXT NOT NULL CHECK (length(full_name) >= 2),
    email TEXT NOT NULL,
    avatar_url TEXT,
    bio TEXT CHECK (length(bio) <= 500),
    tier TEXT DEFAULT 'grassroot' CHECK (tier IN ('grassroot', 'pioneer', 'elder', 'blood')),
    coins BIGINT DEFAULT 1000 CHECK (coins >= 0),
    reputation_score INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Community categories
CREATE TABLE public.community_categories (
    id BIGSERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    icon TEXT DEFAULT '💬',
    color TEXT DEFAULT '#3B82F6',
    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Community posts
CREATE TABLE public.community_posts (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    category_id BIGINT NOT NULL REFERENCES public.community_categories(id) ON DELETE RESTRICT,
    content TEXT NOT NULL CHECK (length(content) >= 1 AND length(content) <= 10000),
    hashtags TEXT[] DEFAULT '{}',
    media_url TEXT,
    media_type TEXT CHECK (media_type IN ('image', 'video', 'audio')),
    vote_count INTEGER DEFAULT 0 CHECK (vote_count >= 0),
    comment_count INTEGER DEFAULT 0 CHECK (comment_count >= 0),
    is_published BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Community comments
CREATE TABLE public.community_comments (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    parent_comment_id BIGINT REFERENCES public.community_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL CHECK (length(content) >= 1 AND length(content) <= 2000),
    like_count INTEGER DEFAULT 0 CHECK (like_count >= 0),
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Post votes (likes)
CREATE TABLE public.community_post_votes (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- Comment likes
CREATE TABLE public.community_comment_likes (
    id BIGSERIAL PRIMARY KEY,
    comment_id BIGINT NOT NULL REFERENCES public.community_comments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(comment_id, user_id)
);

-- Coin transactions
CREATE TABLE public.coin_transactions (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    amount BIGINT NOT NULL,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'reward', 'vote', 'refund', 'subscription')),
    description TEXT,
    status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- MEDIA & CONTENT TABLES
-- =====================================================

-- Media vault items
CREATE TABLE public.media_items (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    media_url TEXT NOT NULL,
    media_type TEXT NOT NULL CHECK (media_type IN ('audio', 'video', 'image', 'document')),
    file_size BIGINT,
    duration INTEGER, -- for audio/video in seconds
    required_tier TEXT DEFAULT 'grassroot' CHECK (required_tier IN ('grassroot', 'pioneer', 'elder', 'blood')),
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chronicles episodes
CREATE TABLE public.chronicles_episodes (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    content TEXT, -- story content
    media_url TEXT, -- optional video/audio
    episode_number INTEGER NOT NULL,
    season_number INTEGER DEFAULT 1,
    required_tier TEXT DEFAULT 'grassroot' CHECK (required_tier IN ('grassroot', 'pioneer', 'elder', 'blood')),
    is_published BOOLEAN DEFAULT FALSE,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- COMMERCE TABLES
-- =====================================================

-- Products (merch)
CREATE TABLE public.products (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price_naira INTEGER NOT NULL CHECK (price_naira >= 0),
    price_coins INTEGER DEFAULT 0 CHECK (price_coins >= 0),
    image_url TEXT,
    category TEXT DEFAULT 'merchandise',
    required_tier TEXT DEFAULT 'grassroot' CHECK (required_tier IN ('grassroot', 'pioneer', 'elder', 'blood')),
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Product variants (sizes, colors)
CREATE TABLE public.product_variants (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    name TEXT NOT NULL, -- e.g., "Large", "Red", "XL Red"
    price_adjustment INTEGER DEFAULT 0, -- additional cost
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders
CREATE TABLE public.orders (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    total_naira INTEGER NOT NULL CHECK (total_naira >= 0),
    total_coins INTEGER DEFAULT 0 CHECK (total_coins >= 0),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled')),
    payment_method TEXT CHECK (payment_method IN ('paystack', 'coins', 'mixed')),
    payment_reference TEXT,
    shipping_address JSONB,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order items
CREATE TABLE public.order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
    variant_id BIGINT REFERENCES public.product_variants(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price_naira INTEGER NOT NULL CHECK (unit_price_naira >= 0),
    unit_price_coins INTEGER DEFAULT 0 CHECK (unit_price_coins >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Events
CREATE TABLE public.events (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    venue TEXT,
    ticket_price INTEGER DEFAULT 0 CHECK (ticket_price >= 0),
    max_capacity INTEGER,
    current_reservations INTEGER DEFAULT 0 CHECK (current_reservations >= 0),
    required_tier TEXT DEFAULT 'grassroot' CHECK (required_tier IN ('grassroot', 'pioneer', 'elder', 'blood')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Event tickets/reservations
CREATE TABLE public.event_tickets (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    ticket_code TEXT UNIQUE NOT NULL DEFAULT gen_random_uuid()::text,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'used', 'cancelled')),
    payment_reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(event_id, user_id)
);

-- =====================================================
-- SUBSCRIPTION TABLES
-- =====================================================

-- Subscription plans
CREATE TABLE public.subscription_plans (
    id BIGSERIAL PRIMARY KEY,
    tier TEXT UNIQUE NOT NULL CHECK (tier IN ('grassroot', 'pioneer', 'elder', 'blood')),
    name TEXT NOT NULL,
    price_monthly INTEGER NOT NULL CHECK (price_monthly >= 0),
    description TEXT,
    features JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User subscriptions
CREATE TABLE public.user_subscriptions (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    plan_id BIGINT NOT NULL REFERENCES public.subscription_plans(id) ON DELETE RESTRICT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired', 'pending')),
    current_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    payment_reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Users indexes
CREATE INDEX idx_users_auth_user_id ON public.users(auth_user_id);
CREATE INDEX idx_users_username ON public.users(username);
CREATE INDEX idx_users_tier ON public.users(tier);
CREATE INDEX idx_users_created_at ON public.users(created_at DESC);

-- Posts indexes
CREATE INDEX idx_community_posts_user_id ON public.community_posts(user_id);
CREATE INDEX idx_community_posts_category_id ON public.community_posts(category_id);
CREATE INDEX idx_community_posts_created_at ON public.community_posts(created_at DESC);
CREATE INDEX idx_community_posts_vote_count ON public.community_posts(vote_count DESC);
CREATE INDEX idx_community_posts_published ON public.community_posts(is_published, is_deleted);

-- Comments indexes
CREATE INDEX idx_community_comments_post_id ON public.community_comments(post_id);
CREATE INDEX idx_community_comments_user_id ON public.community_comments(user_id);
CREATE INDEX idx_community_comments_created_at ON public.community_comments(created_at DESC);

-- Votes indexes
CREATE INDEX idx_community_post_votes_post_id ON public.community_post_votes(post_id);
CREATE INDEX idx_community_post_votes_user_id ON public.community_post_votes(user_id);

-- Media indexes
CREATE INDEX idx_media_items_tier ON public.media_items(required_tier);
CREATE INDEX idx_media_items_type ON public.media_items(media_type);
CREATE INDEX idx_media_items_featured ON public.media_items(is_featured, is_active);

-- Commerce indexes
CREATE INDEX idx_products_active ON public.products(is_active);
CREATE INDEX idx_products_tier ON public.products(required_tier);
CREATE INDEX idx_orders_user_id ON public.orders(user_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_created_at ON public.orders(created_at DESC);

-- Events indexes
CREATE INDEX idx_events_date ON public.events(event_date);
CREATE INDEX idx_events_active ON public.events(is_active);
CREATE INDEX idx_event_tickets_user_id ON public.event_tickets(user_id);
CREATE INDEX idx_event_tickets_event_id ON public.event_tickets(event_id);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Auto-create user profile on auth signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.users (
        auth_user_id,
        username,
        full_name,
        email,
        avatar_url
    ) VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        NEW.email,
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Failed to create user profile: %', SQLERRM;
        RETURN NEW;
END;
$$;

-- Handle post voting with coin rewards
CREATE OR REPLACE FUNCTION public.handle_post_vote(
    p_post_id BIGINT,
    p_voter_auth_id UUID,
    p_coin_amount INTEGER DEFAULT 100
)
RETURNS JSONB 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
DECLARE
    v_voter_id UUID;
    v_post_creator_id UUID;
    v_existing_vote_id BIGINT;
    v_voter_coins BIGINT;
BEGIN
    -- Get voter's ID and coins
    SELECT id, coins INTO v_voter_id, v_voter_coins
    FROM public.users 
    WHERE auth_user_id = p_voter_auth_id;
    
    IF v_voter_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Voter not found');
    END IF;
    
    -- Get post creator's ID
    SELECT user_id INTO v_post_creator_id
    FROM public.community_posts 
    WHERE id = p_post_id AND is_published = true AND is_deleted = false;
    
    IF v_post_creator_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Post not found');
    END IF;
    
    -- Check if voter is trying to vote on their own post
    IF v_voter_id = v_post_creator_id THEN
        RETURN jsonb_build_object('success', false, 'message', 'Cannot vote on your own post');
    END IF;
    
    -- Check if user has already voted
    SELECT id INTO v_existing_vote_id
    FROM public.community_post_votes 
    WHERE post_id = p_post_id AND user_id = v_voter_id;
    
    IF v_existing_vote_id IS NOT NULL THEN
        -- Remove vote
        DELETE FROM public.community_post_votes WHERE id = v_existing_vote_id;
        
        -- Update post vote count
        UPDATE public.community_posts 
        SET vote_count = GREATEST(vote_count - 1, 0),
            updated_at = NOW()
        WHERE id = p_post_id;
        
        -- Refund coins to voter
        UPDATE public.users 
        SET coins = coins + p_coin_amount,
            updated_at = NOW()
        WHERE id = v_voter_id;
        
        -- Remove coins from post creator
        UPDATE public.users 
        SET coins = GREATEST(coins - p_coin_amount, 0),
            reputation_score = GREATEST(reputation_score - 10, 0),
            updated_at = NOW()
        WHERE id = v_post_creator_id;
        
        -- Record refund transaction
        INSERT INTO public.coin_transactions (user_id, amount, transaction_type, description)
        VALUES (v_voter_id, p_coin_amount, 'refund', 'Vote removed - refund');
        
        RETURN jsonb_build_object('success', true, 'action', 'removed', 'voted', false);
    ELSE
        -- Check if voter has enough coins
        IF v_voter_coins < p_coin_amount THEN
            RETURN jsonb_build_object('success', false, 'message', 'Insufficient coins');
        END IF;
        
        -- Add vote
        INSERT INTO public.community_post_votes (post_id, user_id)
        VALUES (p_post_id, v_voter_id);
        
        -- Update post vote count
        UPDATE public.community_posts 
        SET vote_count = vote_count + 1,
            updated_at = NOW()
        WHERE id = p_post_id;
        
        -- Transfer coins from voter
        UPDATE public.users 
        SET coins = coins - p_coin_amount,
            updated_at = NOW()
        WHERE id = v_voter_id;
        
        -- Give coins to post creator
        UPDATE public.users 
        SET coins = coins + p_coin_amount,
            reputation_score = reputation_score + 10,
            updated_at = NOW()
        WHERE id = v_post_creator_id;
        
        -- Record transactions
        INSERT INTO public.coin_transactions (user_id, amount, transaction_type, description)
        VALUES 
        (v_voter_id, -p_coin_amount, 'vote', 'Post vote'),
        (v_post_creator_id, p_coin_amount, 'reward', 'Post vote received');
        
        RETURN jsonb_build_object('success', true, 'action', 'added', 'voted', true);
    END IF;
END;
$$;

-- Update counts when posts/comments are added/removed
CREATE OR REPLACE FUNCTION public.update_counts()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_TABLE_NAME = 'community_posts' THEN
        IF TG_OP = 'INSERT' THEN
            -- No action needed, counts are managed by queries
            NULL;
        ELSIF TG_OP = 'DELETE' THEN
            -- No action needed, counts are managed by queries
            NULL;
        END IF;
    ELSIF TG_TABLE_NAME = 'community_comments' THEN
        IF TG_OP = 'INSERT' THEN
            UPDATE public.community_posts 
            SET comment_count = comment_count + 1, updated_at = NOW() 
            WHERE id = NEW.post_id;
        ELSIF TG_OP = 'DELETE' THEN
            UPDATE public.community_posts 
            SET comment_count = GREATEST(comment_count - 1, 0), updated_at = NOW() 
            WHERE id = OLD.post_id;
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

-- =====================================================
-- TRIGGERS
-- =====================================================

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER trigger_update_comment_counts
    AFTER INSERT OR DELETE ON public.community_comments
    FOR EACH ROW EXECUTE FUNCTION public.update_counts();

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_post_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_comment_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coin_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chronicles_episodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies
CREATE POLICY "Users can view all profiles" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = auth_user_id);

CREATE POLICY "Anyone can view categories" ON public.community_categories FOR SELECT USING (is_active = true);

CREATE POLICY "Anyone can view published posts" ON public.community_posts FOR SELECT USING (is_published = true AND is_deleted = false);
CREATE POLICY "Users can create posts" ON public.community_posts FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Users can edit own posts" ON public.community_posts FOR UPDATE USING (auth.uid() = (SELECT auth_user_id FROM public.users WHERE id = user_id));

CREATE POLICY "Anyone can view comments" ON public.community_comments FOR SELECT USING (is_deleted = false);
CREATE POLICY "Users can create comments" ON public.community_comments FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Users can edit own comments" ON public.community_comments FOR UPDATE USING (auth.uid() = (SELECT auth_user_id FROM public.users WHERE id = user_id));

CREATE POLICY "Users can view votes" ON public.community_post_votes FOR SELECT USING (true);
CREATE POLICY "Users can vote" ON public.community_post_votes FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Users can delete own votes" ON public.community_post_votes FOR DELETE USING (auth.uid() = (SELECT auth_user_id FROM public.users WHERE id = user_id));

CREATE POLICY "Users can view own transactions" ON public.coin_transactions FOR SELECT USING (auth.uid() = (SELECT auth_user_id FROM public.users WHERE id = user_id));

CREATE POLICY "Anyone can view active media" ON public.media_items FOR SELECT USING (is_active = true);
CREATE POLICY "Anyone can view published episodes" ON public.chronicles_episodes FOR SELECT USING (is_published = true);
CREATE POLICY "Anyone can view active products" ON public.products FOR SELECT USING (is_active = true);
CREATE POLICY "Anyone can view active variants" ON public.product_variants FOR SELECT USING (is_active = true);
CREATE POLICY "Anyone can view active events" ON public.events FOR SELECT USING (is_active = true);
CREATE POLICY "Anyone can view subscription plans" ON public.subscription_plans FOR SELECT USING (is_active = true);

CREATE POLICY "Users can view own orders" ON public.orders FOR SELECT USING (auth.uid() = (SELECT auth_user_id FROM public.users WHERE id = user_id));
CREATE POLICY "Users can create orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can view own tickets" ON public.event_tickets FOR SELECT USING (auth.uid() = (SELECT auth_user_id FROM public.users WHERE id = user_id));
CREATE POLICY "Users can create tickets" ON public.event_tickets FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can view own subscriptions" ON public.user_subscriptions FOR SELECT USING (auth.uid() = (SELECT auth_user_id FROM public.users WHERE id = user_id));

-- =====================================================
-- SEED DATA
-- =====================================================

-- Insert default categories
INSERT INTO public.community_categories (name, slug, description, icon, color, display_order) VALUES
('General Discussion', 'general', 'General discussions about Erigga and his music', '💬', '#3B82F6', 1),
('Music & Lyrics', 'music', 'Discuss Erigga''s music, lyrics, and their meanings', '🎵', '#10B981', 2),
('Events & Shows', 'events', 'Information about upcoming events and shows', '🎤', '#EF4444', 3),
('Freestyle Corner', 'freestyle', 'Share your own freestyle lyrics and get feedback', '🔥', '#F59E0B', 4),
('Fan Art', 'art', 'Share your Erigga-inspired artwork', '🎨', '#8B5CF6', 5),
('News & Updates', 'news', 'Latest news and updates about Erigga', '📰', '#06B6D4', 6);

-- Insert subscription plans
INSERT INTO public.subscription_plans (tier, name, price_monthly, description, features) VALUES
('grassroot', 'Grassroot', 0, 'Basic access to the platform', '["Community access", "Public content", "Event announcements"]'),
('pioneer', 'Pioneer', 2000, 'Enhanced access with exclusive content', '["All Grassroot features", "Early music releases", "Exclusive interviews", "Discounted merch"]'),
('elder', 'Elder', 5000, 'Premium access with VIP benefits', '["All Pioneer features", "Behind-the-scenes content", "Studio session videos", "Priority event access", "Monthly coins"]'),
('blood', 'Blood Brotherhood', 10000, 'Ultimate fan experience', '["All Elder features", "Direct messaging", "Virtual meet & greets", "Exclusive merchandise", "Voting rights"]');

-- =====================================================
-- REALTIME & PERMISSIONS
-- =====================================================

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.users;
ALTER PUBLICATION supabase_realtime ADD TABLE public.community_posts;
ALTER PUBLICATION supabase_realtime ADD TABLE public.community_comments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.community_post_votes;

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '=== CLEAN MINIMAL SCHEMA CREATED SUCCESSFULLY ===';
    RAISE NOTICE 'Categories: %', (SELECT COUNT(*) FROM public.community_categories);
    RAISE NOTICE 'Subscription Plans: %', (SELECT COUNT(*) FROM public.subscription_plans);
    RAISE NOTICE '=== READY FOR USE ===';
END $$;
