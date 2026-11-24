"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { createContext, useContext, useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";

type Admin = { id: string; name: string };

const AdminContext = createContext<Admin | null>(null);

/** The signed-in admin. Only valid inside <Shell>. */
export function useAdmin(): Admin {
  const admin = useContext(AdminContext);
  if (!admin) throw new Error("useAdmin outside Shell");
  return admin;
}

/**
 * Page frame for signed-in admins. Sends anyone else to /login. This is a
 * convenience only: the database decides what a session may read or change.
 */
export default function Shell({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [admin, setAdmin] = useState<Admin | null>(null);
  const [pending, setPending] = useState(0);
  const [openFlags, setOpenFlags] = useState(0);

  useEffect(() => {
    let active = true;

    async function check() {
      const { data } = await supabase.auth.getSession();
      if (!data.session) {
        router.replace("/login");
        return;
      }
      const { data: profile } = await supabase
        .from("users")
        .select("id, name, role, is_active")
        .eq("auth_user_id", data.session.user.id)
        .maybeSingle();
      if (!active) return;
      if (!profile || profile.role !== "admin" || !profile.is_active) {
        await supabase.auth.signOut();
        router.replace("/login?denied=1");
        return;
      }
      setAdmin({ id: profile.id, name: profile.name });
    }
    check();

    const { data: sub } = supabase.auth.onAuthStateChange((event) => {
      if (event === "SIGNED_OUT") router.replace("/login");
    });
    return () => {
      active = false;
      sub.subscription.unsubscribe();
    };
  }, [router]);

  useEffect(() => {
    if (!admin) return;
    let active = true;
    async function count() {
      const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
      const { count } = await supabase
        .from("login_requests")
        .select("id", { count: "exact", head: true })
        .eq("status", "pending")
        .gt("created_at", since);
      if (active) setPending(count ?? 0);
    }
    count();
    const timer = setInterval(count, 5000);
    return () => {
      active = false;
      clearInterval(timer);
    };
  }, [admin]);

  // Flags waiting for review, for the badge on "Flags".
  useEffect(() => {
    if (!admin) return;
    let active = true;
    async function count() {
      const { data } = await supabase.rpc("admin_open_flags");
      if (active && data) setOpenFlags((data as { open: number }).open);
    }
    count();
    const timer = setInterval(count, 30_000);
    return () => {
      active = false;
      clearInterval(timer);
    };
  }, [admin, pathname]);

  if (!admin) {
    return (
      <div className="center">
        <p className="muted">Loading…</p>
      </div>
    );
  }

  const links = [
    { href: "/", label: "Dashboard", count: 0 },
    { href: "/activity", label: "Activity", count: 0 },
    { href: "/requests", label: "Sign-in requests", count: pending },
    { href: "/forms", label: "Forms", count: 0 },
    { href: "/flags", label: "Flags", count: openFlags },
    { href: "/volunteers", label: "Field team", count: 0 },
    { href: "/admins", label: "Admins", count: 0 },
  ];

  return (
    <AdminContext.Provider value={admin}>
      <header className="topbar">
        <div className="topbar-inner">
          <div className="brand">
            दस्तक <span>Admin</span>
          </div>
          <nav className="nav">
            {links.map((link) => (
              <Link key={link.href} href={link.href} className={pathname === link.href ? "active" : ""}>
                {link.label}
                {link.count > 0 && <span className="badge-count">{link.count}</span>}
              </Link>
            ))}
          </nav>
          <div className="who">
            {admin.name}
            <button className="small" onClick={() => supabase.auth.signOut()}>
              Sign out
            </button>
          </div>
        </div>
      </header>
      <main className="page">{children}</main>
    </AdminContext.Provider>
  );
}
