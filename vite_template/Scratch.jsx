import * as React from "react";
import styled from "styled-components";

function ScratchMain() {
  return <StyleMain>TEST COMPONENT</StyleMain>;
}

const StyleScratch = styled.div`
  width: 100%;
  height: 100%;
  display: grid;
  grid-template-rows: 1fr 50px;
  grid-template-columns: 1fr;
  grid-template-areas: "main" "footer";
  gap: 50px;
  padding: 20px;
  background-color: grey;
`;

const StyleFooter = styled.footer`
  grid-area: footer;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 2rem;
  color: orange;
  font-weight: bold;
`;

const StyleMain = styled.div`
  grid-area: main;
  height: 100%;
  background-color: white;
  display: flex;
  justify-content: center;
  align-items: center;
`;

function ScratchFooter() {
  return (
    <StyleFooter>
      <span>*Scratch Buffer*</span>
    </StyleFooter>
  );
}

function Scratch() {
  return (
    <StyleScratch>
      <ScratchMain />
      <ScratchFooter />
    </StyleScratch>
  );
}

export { Scratch };
