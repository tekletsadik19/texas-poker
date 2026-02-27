import http from "k6/http";
import { check } from "k6";

export const options = {
  vus: 100,
  duration: "10s",
  thresholds: {
    http_req_duration: ["p(95)<500"], // 95% of requests should be below 500ms
  },
};

export default function () {
  const payload = JSON.stringify({
    hole: ["HA", "SA"],
    community: [],
    num_players: 5,
    simulations: 10000,
  });

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  const res = http.post(
    "http://localhost:8081/hand/probability",
    payload,
    params,
  );

  check(res, {
    "is status 200": (r) => r.status === 200,
  });
}
