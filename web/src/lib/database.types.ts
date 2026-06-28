export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
      families: {
        Row: {
          id: string;
          name: string;
          grandpa_name: string;
          invite_code: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          grandpa_name: string;
          invite_code: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          grandpa_name?: string;
          invite_code?: string;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      profiles: {
        Row: {
          id: string;
          email: string;
          display_name: string | null;
          family_id: string | null;
          phone: string | null;
          color_hex: string;
          avatar_url: string | null;
          google_calendar_connected: boolean;
          google_refresh_token: string | null;
          schedule_days_showed: number;
          created_at: string;
        };
        Insert: {
          id: string;
          email: string;
          display_name?: string | null;
          family_id?: string | null;
          phone?: string | null;
          color_hex?: string;
          avatar_url?: string | null;
          google_calendar_connected?: boolean;
          google_refresh_token?: string | null;
          schedule_days_showed?: number;
          created_at?: string;
        };
        Update: {
          id?: string;
          email?: string;
          display_name?: string | null;
          family_id?: string | null;
          phone?: string | null;
          color_hex?: string;
          avatar_url?: string | null;
          google_calendar_connected?: boolean;
          google_refresh_token?: string | null;
          schedule_days_showed?: number;
          created_at?: string;
        };
        Relationships: [];
      };
      family_members: {
        Row: {
          id: string;
          family_id: string;
          user_id: string | null;
          name: string;
          phone: string | null;
          color_hex: string;
          avatar_url: string | null;
          role: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          family_id: string;
          user_id?: string | null;
          name: string;
          phone?: string | null;
          color_hex?: string;
          avatar_url?: string | null;
          role?: string;
          created_at?: string;
        };
        Update: {
          id?: string;
          family_id?: string;
          user_id?: string | null;
          name?: string;
          phone?: string | null;
          color_hex?: string;
          avatar_url?: string | null;
          role?: string;
          created_at?: string;
        };
        Relationships: [];
      };
      shifts: {
        Row: {
          id: string;
          family_id: string;
          assigned_member_id: string;
          shift_date: string;
          start_hour: number;
          start_minute: number;
          duration_minutes: number;
          end_time: string;
          notes: string | null;
          reminder_offset_minutes: number[];
          calendar_event_id: string | null;
          status: string;
          repeat_rule: Json | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          family_id: string;
          assigned_member_id: string;
          shift_date: string;
          start_hour: number;
          start_minute: number;
          duration_minutes: number;
          end_time: string;
          notes?: string | null;
          reminder_offset_minutes?: number[];
          calendar_event_id?: string | null;
          status?: string;
          repeat_rule?: Json | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          family_id?: string;
          assigned_member_id?: string;
          shift_date?: string;
          start_hour?: number;
          start_minute?: number;
          duration_minutes?: number;
          end_time?: string;
          notes?: string | null;
          reminder_offset_minutes?: number[];
          calendar_event_id?: string | null;
          status?: string;
          repeat_rule?: Json | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      unavailabilities: {
        Row: {
          id: string;
          family_id: string;
          member_id: string;
          block_date: string;
          start_hour: number;
          start_minute: number;
          duration_minutes: number;
          end_time: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          family_id: string;
          member_id: string;
          block_date: string;
          start_hour: number;
          start_minute: number;
          duration_minutes: number;
          end_time: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          family_id?: string;
          member_id?: string;
          block_date?: string;
          start_hour?: number;
          start_minute?: number;
          duration_minutes?: number;
          end_time?: string;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      notifications: {
        Row: {
          id: string;
          family_id: string;
          user_id: string;
          type: string;
          shift_id: string | null;
          title: string;
          body: string;
          read: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          family_id: string;
          user_id: string;
          type: string;
          shift_id?: string | null;
          title: string;
          body: string;
          read?: boolean;
          created_at?: string;
        };
        Update: {
          id?: string;
          family_id?: string;
          user_id?: string;
          type?: string;
          shift_id?: string | null;
          title?: string;
          body?: string;
          read?: boolean;
          created_at?: string;
        };
        Relationships: [];
      };
      family_settings: {
        Row: {
          family_id: string;
          coverage_fallback_member_ids: string[];
          updated_at: string;
        };
        Insert: {
          family_id: string;
          coverage_fallback_member_ids?: string[];
          updated_at?: string;
        };
        Update: {
          family_id?: string;
          coverage_fallback_member_ids?: string[];
          updated_at?: string;
        };
        Relationships: [];
      };
      push_subscriptions: {
        Row: {
          id: string;
          user_id: string;
          endpoint: string;
          p256dh: string;
          auth_key: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          endpoint: string;
          p256dh: string;
          auth_key: string;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          endpoint?: string;
          p256dh?: string;
          auth_key?: string;
          created_at?: string;
        };
        Relationships: [];
      };
    };
    Views: Record<string, never>;
    Functions: {
      create_family: {
        Args: { p_name: string; p_grandpa_name: string };
        Returns: Tables<"profiles">;
      };
      join_family: {
        Args: { p_invite_code: string };
        Returns: Tables<"profiles">;
      };
      get_my_profile: {
        Args: Record<string, never>;
        Returns: Tables<"profiles">;
      };
    };
    Enums: Record<string, never>;
  };
}

export type Tables<T extends keyof Database["public"]["Tables"]> =
  Database["public"]["Tables"][T]["Row"];

export type Family = Tables<"families">;
export type Profile = Tables<"profiles">;
export type FamilyMember = Tables<"family_members">;
export type Shift = Tables<"shifts">;
export type Unavailability = Tables<"unavailabilities">;
export type AppNotification = Tables<"notifications">;
export type FamilySettings = Tables<"family_settings">;
