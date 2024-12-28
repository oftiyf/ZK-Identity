import { useState } from "react";
import "./App.css";
import Demo1 from "./demos/demo1";

function App() {
  const [count, setCount] = useState(0);

  return (
    <>
      <Demo1 />
    </>
  );
}

export default App;
