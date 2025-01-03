import { getCollection } from "astro:content";
import { siteConfig } from "@/site.config";
import rss from "@astrojs/rss";
import sanitizeHtml from 'sanitize-html';
import MarkdownIt from 'markdown-it';

const parser = new MarkdownIt();

export const GET = async () => {
	const notes = await getCollection("note");

	return rss({
		title: "ToniTypes Notes",
		description: "Collection of notes, not long enough for whole article",
		site: import.meta.env.SITE,
		items: notes.map((note) => ({
      author: siteConfig.author,
			title: note.data.title,
			pubDate: note.data.publishDate,
			link: `notes/${note.id}/`,
      content: sanitizeHtml(parser.render(note.body), {
        allowedTags: sanitizeHtml.defaults.allowedTags.concat(['img'])
      }),
		})),
	});
};
