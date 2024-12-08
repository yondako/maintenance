import template from "./template.html";

export default {
  async fetch(request, env, _ctx): Promise<Response> {
    const clientIP = request.headers.get("CF-Connecting-IP");

    const whiteList = await env.YONDAKO_MAINTENANCE.get("whiteList");
    const ipList = whiteList?.split(",");

    if (clientIP && ipList?.includes(clientIP)) {
      return await fetch(request);
    }

    const startedAt = await env.YONDAKO_MAINTENANCE.get("startDate");
    const endedAt = await env.YONDAKO_MAINTENANCE.get("endDate");

    if (!startedAt || !endedAt) {
      return new Response("Invalid maintenance time", {
        status: 503,
      });
    }

    const [startDate, startTime] = startedAt.split(" ");
    const [endDate, endTime] = endedAt.split(" ");

    const html = template
      .replaceAll("{{startDate}}", startDate)
      .replaceAll("{{startTime}}", startTime)
      .replaceAll("{{endDate}}", endDate)
      .replaceAll("{{endTime}}", endTime);

    return new Response(html, {
      headers: { "Content-Type": "text/html" },
      status: 503,
    });
  },
} satisfies ExportedHandler<Env>;
