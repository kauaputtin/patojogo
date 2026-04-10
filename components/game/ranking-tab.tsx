"use client";

import { cn } from "@/lib/cn";
import type { Tables } from "@/lib/database.types";

type RankingProfile = Pick<
  Tables<"profiles">,
  "id" | "full_name" | "phone" | "score"
>;

interface RankingTabProps {
  profiles: RankingProfile[];
  currentUserId?: string;
}

export function RankingTab({ profiles, currentUserId }: RankingTabProps) {
  const getMedalOrNumber = (position: number) => {
    if (position === 1) return "🥇";
    if (position === 2) return "🥈";
    if (position === 3) return "🥉";
    return position;
  };

  return (
    <section className="flex flex-col flex-1 gap-3 rounded-[1.8rem] border border-white/10 bg-[#12225a]/24 p-4 shadow-[0_24px_48px_rgba(7,12,40,0.22)] sm:rounded-[2rem] sm:p-5">
      <header className="flex items-center gap-2 mb-2">
        <span className="h-5 w-5 text-lg">🏆</span>
        <p className="text-[0.64rem] font-semibold uppercase tracking-[0.28em] text-[#8da6ff] sm:text-[0.68rem]">
          Ranking Geral
        </p>
      </header>

      <div className="flex flex-col gap-2 overflow-y-auto pr-2 pb-4">
        {profiles.length === 0 ? (
          <div className="flex items-center justify-center py-8 text-center text-[#a7bcff]">
            <p className="text-sm">Nenhum jogador encontrado no ranking</p>
          </div>
        ) : (
          profiles.map((profile, index) => {
            const position = index + 1;
            const isCurrentUser = profile.id === currentUserId;

            return (
              <div
                key={profile.id}
                className={cn(
                  "flex items-center justify-between rounded-[1rem] px-3 py-2.5 border transition-all",
                  isCurrentUser
                    ? "border-[#2c7dff] bg-[#2c7dff]/15 ring-1 ring-[#2c7dff]/30"
                    : "border-white/8 bg-white/[0.03] hover:bg-white/[0.06]",
                )}
              >
                {/* Posição + Nome */}
                <div className="flex items-center gap-2.5 min-w-0">
                  <span className="flex items-center justify-center w-6 font-bold text-[#a7bcff] flex-shrink-0">
                    {typeof getMedalOrNumber(position) === "string"
                      ? getMedalOrNumber(position)
                      : `#${getMedalOrNumber(position)}`}
                  </span>

                  <div className="flex flex-col min-w-0">
                    <span className="text-sm font-medium text-white truncate">
                      {profile.full_name}
                      {isCurrentUser && (
                        <span className="text-[#2c7dff] font-semibold ml-1">
                          (Você)
                        </span>
                      )}
                    </span>
                    {profile.phone && (
                      <span className="text-xs text-[#a7bcff] truncate">
                        {profile.phone}
                      </span>
                    )}
                  </div>
                </div>

                {/* Pontuação */}
                <span className="text-[#2c7dff] font-bold text-sm ml-2 flex-shrink-0">
                  {profile.score ?? 0}
                </span>
              </div>
            );
          })
        )}
      </div>
    </section>
  );
}
