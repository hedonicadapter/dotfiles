import Wp from "gi://AstalWp";

const endpoints = Wp.get_default().endpoints;
console.log(endpoints);

endpoints.forEach((endpoint) => {
  console.log(endpoint.get_id());
  console.log(endpoint.get_name());
  console.log(endpoint.get_volume());

  console.log(endpoint.id);
  console.log(endpoint.name);
  console.log(endpoint.volume);
});
export default function () {
  return <box />;
}
