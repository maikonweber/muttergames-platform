import type { MetadataRoute } from "next";
export default function sitemap(): MetadataRoute.Sitemap { return ["", "/games", "/ecosystem"].map((path) => ({ url: `https://mutter.games${path}`, lastModified: new Date(), changeFrequency: "weekly" as const, priority: path === "" ? 1 : .8 })); }
