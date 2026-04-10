import { AuthPanel } from "@/components/auth/auth-panel";
import { GameShell } from "@/components/game/game-shell";
import type { Tables } from "@/lib/database.types";
import { createClient } from "@/lib/supabase/server";

type Profile = Pick<
  Tables<"profiles">,
  "email" | "full_name" | "phone" | "progress_step" | "score"
>;

type RankingProfile = Pick<
  Tables<"profiles">,
  "id" | "full_name" | "phone" | "score"
>;

export const dynamic = "force-dynamic";

export default async function Home() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  let profile: Profile | null = null;
  let rankingProfiles: RankingProfile[] = [];

  if (user) {
    const { data } = await supabase
      .from("profiles")
      .select("email, full_name, phone, progress_step, score")
      .eq("id", user.id)
      .maybeSingle();

    profile = data;

    // Fetch ranking data
    const { data: ranking } = await supabase
      .from("profiles")
      .select("id, full_name, phone, score")
      .order("score", { ascending: false });

    rankingProfiles = ranking ?? [];
  }

  return (
    <main>
      {!profile ? (
        <AuthPanel />
      ) : (
        <GameShell profile={profile} rankingProfiles={rankingProfiles} currentUserId={user?.id} />
      )}
    </main>
  );
}
