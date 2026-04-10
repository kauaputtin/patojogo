"use client";

import { useState } from "react";
import { AppMark } from "@/components/auth/app-mark";
import { SignOutButton } from "@/components/auth/sign-out-button";
import { RankingTab } from "@/components/game/ranking-tab";
import { cn } from "@/lib/cn";
import type { Tables } from "@/lib/database.types";

type Profile = {
  email: string | null;
  full_name: string | null;
  phone: string | null;
  progress_step: number | null;
  score: number | null;
};

type RankingProfile = Pick<
  Tables<"profiles">,
  "id" | "full_name" | "phone" | "score"
>;

type GameShellProps = {
  profile: Profile;
  rankingProfiles?: RankingProfile[];
  currentUserId?: string;
};

type TabId = "extras" | "shop" | "play" | "ranking" | "account";

const navItems: Array<{
  id: TabId;
  label: string;
  icon: React.ReactNode;
}> = [
  {
    id: "extras",
    label: "Extras",
    icon: <SparkIcon />,
  },
  {
    id: "shop",
    label: "Loja",
    icon: <BagIcon />,
  },
  {
    id: "play",
    label: "Jogar",
    icon: <GamepadIcon />,
  },
  {
    id: "ranking",
    label: "Ranking",
    icon: <CupIcon />,
  },
  {
    id: "account",
    label: "Conta",
    icon: <UserIcon />,
  },
];

const playModes = [
  {
    accent: "from-[#2c7dff] via-[#1e54ff] to-[#1832ca]",
    description:
      "Siga a trilha principal da palestra e avance com perguntas mais guiadas.",
    icon: <StackIcon />,
    iconSurface: "bg-[linear-gradient(180deg,#7ad1ff,#3f7dff)]",
    title: "Quiz guiado",
  },
  {
    accent: "from-[#8d2dff] via-[#b61dff] to-[#d53cff]",
    description:
      "Entre numa rodada curta, mais intensa e com foco em pontuação rápida.",
    icon: <LightningSwordsIcon />,
    iconSurface: "bg-[linear-gradient(180deg,#f4a8ff,#9336ff)]",
    title: "Desafio relampago",
  },
];

export function GameShell({ profile, rankingProfiles = [], currentUserId }: GameShellProps) {
  const [activeTab, setActiveTab] = useState<TabId>("play");
  const activeItem = navItems.find((item) => item.id === activeTab) ?? navItems[2];
  const firstName = profile.full_name?.split(" ")[0] ?? "Participante";

  return (
    <div className="min-h-[100dvh] overflow-x-hidden bg-[radial-gradient(circle_at_top,rgba(103,141,255,0.24),transparent_22%),linear-gradient(180deg,#1e2f83_0%,#223da9_54%,#202a87_100%)] text-white">
      <div className="mx-auto flex min-h-[100dvh] w-full max-w-[28rem] flex-col px-3 pb-[calc(env(safe-area-inset-bottom)+0.9rem)] pt-[calc(env(safe-area-inset-top)+0.75rem)] sm:max-w-[30rem] sm:px-4 sm:pb-4 sm:pt-4 lg:max-w-[32rem]">
        <header className="flex flex-wrap items-center justify-between gap-3 rounded-[1.4rem] border border-white/10 bg-[#12205b]/50 px-4 py-3 shadow-[0_18px_45px_rgba(7,12,40,0.32)] backdrop-blur sm:px-5 sm:py-4">
          <div className="flex min-w-0 flex-1 items-center gap-2.5 sm:gap-3">
            <div className="flex h-11 w-11 shrink-0 items-center justify-center overflow-hidden rounded-full sm:h-12 sm:w-12">
              <div className="origin-center scale-[0.54] sm:scale-[0.62]">
                <AppMark />
              </div>
            </div>
            <div className="min-w-0">
              <p className="text-[0.62rem] font-semibold uppercase tracking-[0.26em] text-[#a7bcff] sm:text-[0.68rem]">
                PatoJOGO
              </p>
              <p className="truncate text-sm text-white/92 sm:text-[0.95rem]">
                Ola, {firstName}
              </p>
            </div>
          </div>

          <div className="ml-auto flex shrink-0 items-center gap-2">
            <div className="rounded-full border border-white/12 bg-white/8 px-3 py-1.5 text-[0.74rem] font-semibold text-[#ffe18a] sm:text-xs">
              {profile.score ?? 0} pts
            </div>
            <SignOutButton
              className="min-h-9 rounded-full border-white/10 bg-white/8 px-3 text-[0.74rem] text-white hover:bg-white/12 sm:text-xs"
              label="Sair"
              size="sm"
              variant="ghost"
            />
          </div>
        </header>

        <main className="flex flex-1 flex-col pt-4 pb-24 sm:pt-5 sm:pb-28">
          {activeTab === "play" ? (
            <PlayHub progressStep={profile.progress_step ?? 0} />
          ) : activeTab === "ranking" ? (
            <RankingTab
              profiles={rankingProfiles ?? []}
              currentUserId={currentUserId}
            />
          ) : (
            <BlankTab label={activeItem.label} />
          )}
        </main>

        <div className="sticky bottom-3 z-20 mt-auto pb-[env(safe-area-inset-bottom)] sm:bottom-4">
          <nav className="grid grid-cols-5 gap-1.5 rounded-[1.55rem] border border-white/10 bg-[linear-gradient(180deg,rgba(134,27,214,0.94),rgba(81,28,160,0.94))] p-1.5 shadow-[0_28px_60px_rgba(20,6,53,0.34)] sm:gap-2 sm:rounded-[1.8rem] sm:p-2">
            {navItems.map((item) => {
              const isActive = item.id === activeTab;

              return (
                <button
                  key={item.id}
                  className={cn(
                    "flex min-h-[4.35rem] flex-col items-center justify-center gap-1.5 rounded-[1rem] border border-transparent px-1 py-2 text-[0.63rem] font-medium leading-none text-[#d9d0ff] transition-all sm:min-h-[4.75rem] sm:gap-2 sm:rounded-[1.15rem] sm:px-2 sm:py-3 sm:text-[0.72rem]",
                    isActive
                      ? "border-[#f0b23a] bg-white/10 text-[#ffd95b] shadow-[inset_0_0_0_1px_rgba(255,190,54,0.18)]"
                      : "hover:bg-white/6",
                  )}
                  onClick={() => setActiveTab(item.id)}
                  type="button"
                >
                  <span
                    className={cn(
                      "flex h-5 w-5 items-center justify-center text-current sm:h-6 sm:w-6",
                      isActive && "scale-105",
                    )}
                  >
                    {item.icon}
                  </span>
                  <span className="text-center">{item.label}</span>
                </button>
              );
            })}
          </nav>
        </div>
      </div>
    </div>
  );
}

function PlayHub({ progressStep }: { progressStep: number }) {
  return (
    <section className="space-y-3.5 sm:space-y-4">
      <div className="rounded-[1.8rem] bg-[linear-gradient(135deg,#5b42ff_0%,#8d2dff_48%,#c017ff_100%)] px-5 py-6 text-center shadow-[0_28px_60px_rgba(35,13,85,0.3)] sm:rounded-[2rem] sm:px-6 sm:py-7">
        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-black/14 sm:h-14 sm:w-14">
          <GamepadIcon />
        </div>
        <h1 className="mt-4 text-[2rem] font-semibold tracking-tight text-white sm:text-[2.25rem]">
          Jogar
        </h1>
        <p className="mx-auto mt-2 max-w-[16rem] text-[0.94rem] text-[#ece6ff] sm:max-w-[18rem] sm:text-sm">
          Escolha como quer pontuar na sua proxima rodada.
        </p>
      </div>

      <div className="space-y-3.5 sm:space-y-4">
        {playModes.map((mode) => (
          <button
            key={mode.title}
            className={cn(
              "grid w-full grid-cols-[auto,1fr,auto] items-center gap-3 rounded-[1.55rem] border border-white/18 bg-[linear-gradient(135deg,rgba(255,255,255,0.09),rgba(255,255,255,0.02))] px-4 py-4 text-left shadow-[0_24px_50px_rgba(10,14,45,0.2)] backdrop-blur sm:gap-4 sm:rounded-[1.85rem] sm:px-5 sm:py-5",
              `bg-gradient-to-r ${mode.accent}`,
            )}
            type="button"
          >
            <div
              className={cn(
                "flex h-14 w-14 shrink-0 items-center justify-center rounded-[1rem] shadow-[inset_0_1px_0_rgba(255,255,255,0.24)] sm:h-16 sm:w-16 sm:rounded-[1.2rem]",
                mode.iconSurface,
              )}
            >
              {mode.icon}
            </div>

            <div className="min-w-0 flex-1">
              <h2 className="text-[1.35rem] font-semibold tracking-tight text-white sm:text-[1.55rem]">
                {mode.title}
              </h2>
              <p className="mt-1 text-[0.92rem] leading-6 text-white/84 sm:text-sm">
                {mode.description}
              </p>
            </div>

            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-black/12 text-white sm:h-11 sm:w-11">
              <ArrowIcon />
            </div>
          </button>
        ))}
      </div>

      <div className="rounded-[1.15rem] border border-white/10 bg-[#161f43]/82 px-4 py-4 text-center text-[0.92rem] text-[#d8e0ff] shadow-[0_16px_36px_rgba(8,12,34,0.24)] sm:rounded-[1.35rem] sm:text-sm">
        <span className="font-semibold text-[#ffd261]">Etapa {progressStep}</span>
        {" "}salva. Toda resposta boa sobe sua pontuacao no ranking final.
      </div>
    </section>
  );
}

function BlankTab({ label }: { label: string }) {
  return (
    <section className="flex min-h-[20rem] flex-1 flex-col rounded-[1.8rem] border border-white/10 bg-[#12225a]/24 p-4 shadow-[0_24px_48px_rgba(7,12,40,0.22)] sm:min-h-[32rem] sm:rounded-[2rem] sm:p-5">
      <p className="text-[0.64rem] font-semibold uppercase tracking-[0.28em] text-[#8da6ff] sm:text-[0.68rem]">
        {label}
      </p>
      <div className="mt-4 flex flex-1 rounded-[1.35rem] border border-dashed border-white/10 bg-white/[0.03] sm:rounded-[1.6rem]" />
    </section>
  );
}

function iconProps() {
  return {
    fill: "none",
    stroke: "currentColor",
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
    strokeWidth: 1.8,
    viewBox: "0 0 24 24",
  };
}

function ArrowIcon() {
  return (
    <svg aria-hidden="true" className="h-6 w-6" {...iconProps()}>
      <path d="M5 12h14" />
      <path d="m13 6 6 6-6 6" />
    </svg>
  );
}

function SparkIcon() {
  return (
    <svg aria-hidden="true" className="h-5 w-5" {...iconProps()}>
      <path d="m12 3 1.7 4.3L18 9l-4.3 1.7L12 15l-1.7-4.3L6 9l4.3-1.7z" />
      <path d="M5 16.5 6 19l2.5 1-2.5 1L5 23l-1-2.5L1.5 19 4 18z" />
    </svg>
  );
}

function BagIcon() {
  return (
    <svg aria-hidden="true" className="h-5 w-5" {...iconProps()}>
      <path d="M5 8h14l-1 11H6L5 8Z" />
      <path d="M9 8a3 3 0 0 1 6 0" />
    </svg>
  );
}

function GamepadIcon() {
  return (
    <svg aria-hidden="true" className="h-7 w-7" {...iconProps()}>
      <path d="M7.5 9h9A4.5 4.5 0 0 1 21 13.5v1a3.5 3.5 0 0 1-6 2.4L13.8 16h-3.6L9 16.9a3.5 3.5 0 0 1-6-2.4v-1A4.5 4.5 0 0 1 7.5 9Z" />
      <path d="M8 12v4" />
      <path d="M6 14h4" />
      <path d="M15.5 12h.01" />
      <path d="M18 14h.01" />
    </svg>
  );
}

function CupIcon() {
  return (
    <svg aria-hidden="true" className="h-5 w-5" {...iconProps()}>
      <path d="M8 4h8v3a4 4 0 0 1-8 0V4Z" />
      <path d="M6 5H4a2 2 0 0 0 2 3" />
      <path d="M18 5h2a2 2 0 0 1-2 3" />
      <path d="M12 11v4" />
      <path d="M8 19h8" />
      <path d="M9.5 15h5" />
    </svg>
  );
}

function UserIcon() {
  return (
    <svg aria-hidden="true" className="h-5 w-5" {...iconProps()}>
      <path d="M12 12a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Z" />
      <path d="M5.5 20a6.5 6.5 0 0 1 13 0" />
    </svg>
  );
}

function StackIcon() {
  return (
    <svg
      aria-hidden="true"
      className="h-8 w-8 text-white"
      fill="none"
      stroke="currentColor"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={1.8}
      viewBox="0 0 24 24"
    >
      <path d="M7 5h10v10H7z" />
      <path d="M4 8h10v10H4z" />
      <path d="M10 11h10v10H10z" />
    </svg>
  );
}

function LightningSwordsIcon() {
  return (
    <svg
      aria-hidden="true"
      className="h-8 w-8 text-white"
      fill="none"
      stroke="currentColor"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={1.8}
      viewBox="0 0 24 24"
    >
      <path d="m7 4 4 4-5 9-3-3 9-5 4 4" />
      <path d="m17 4-4 4 5 9 3-3-9-5-4 4" />
    </svg>
  );
}
