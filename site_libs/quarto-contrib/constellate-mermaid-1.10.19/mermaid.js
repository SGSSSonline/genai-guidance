// Mermaid
(() => {
  const diagramRoles = () => {
    const css = getComputedStyle(document.documentElement);
    const role = (name) =>
      css.getPropertyValue(`--constellate-viz-${name}`).trim();
    return {
      role,
      hues: role("hues").split(/\s+/),
      series: role("series-hues").split(/\s+/),
    };
  };
  // Flowchart edge classes
  const mermaidSource = (source, type, { role, hues }) => {
    if (type !== "flowchart-v2" && type !== "flowchart") return source;
    return source + "\n" + hues.map((hue) =>
      `classDef edge-${hue} stroke:${role(`series-${hue}`)};`
    ).join("\n");
  };

  // Mermaid labels
  const labelStyles = `
  .label,.cluster span,.nodeLabel,text.actor>tspan,.labelText,.labelText>span{font-weight:var(--mermaid-font-weight)}
  .label foreignObject{line-height:normal;overflow:visible}
  .loopText>tspan,.messageText,.noteText>tspan{font-weight:var(--mermaid-font-weight)!important}
  .grid .tick line{stroke:var(--constellate-viz-grid)}
  .cluster-label div,.cluster-label span,.cluster-label p,.edgeTerminals div,.edgeTerminals span,.edgeTerminals p{line-height:1!important;}
  `;
  const mermaidConfig = (size, family, { role, series: colours }) => {
    const solid = colours.map((c) => role(`solid-${c}`));
    const text = role("text"),
      bg = role("background"),
      fill = role("node-fill");
    const border = role("node-border"),
      line = role("edge"),
      onSolid = role("on-solid");
    const vars = {
      scaleLabelColor: onSolid,
      fontSize: `${size}px`,
      background: bg,
      primaryColor: fill,
      primaryTextColor: text,
      primaryBorderColor: border,
      secondaryColor: fill,
      secondaryTextColor: text,
      secondaryBorderColor: border,
      tertiaryColor: fill,
      tertiaryTextColor: text,
      tertiaryBorderColor: border,
      lineColor: line,
      edgeLabelBackground: bg,
      actorBkg: bg,
      signalColor: line,
      arrowheadColor: line,
      labelTextColor: border,
      labelBoxBkgColor: fill,
      noteBkgColor: fill,
      noteTextColor: text,
      noteBorderColor: border,
      activationBorderColor: border,
      sequenceNumberColor: onSolid,
      attributeBackgroundColorOdd: bg,
      attributeBackgroundColorEven: fill,
      altBackground: bg,
      labelBackgroundColor: bg,
      sectionBkgColor: bg,
      altSectionBkgColor: bg,
      sectionBkgColor2: bg,
      taskBkgColor: solid[0],
      taskBorderColor: bg,
      taskTextColor: onSolid,
      taskTextLightColor: onSolid,
      taskTextDarkColor: onSolid,
      taskTextClickableColor: onSolid,
      activeTaskBkgColor: solid[2],
      activeTaskBorderColor: bg,
      doneTaskBkgColor: solid[6],
      doneTaskBorderColor: bg,
      critBkgColor: solid[7],
      critBorderColor: bg,
      todayLineColor: solid[7],
      gridColor: role("grid"),
      darkMode: role("dark-mode") === "true",
      pieSectionTextSize: `${size}px`,
      pieSectionTextColor: onSolid,
      pieTitleTextSize: `${size * 1.1}px`,
      pieTitleTextColor: text,
      pieLegendTextSize: `${size}px`,
      pieLegendTextColor: text,
      pieStrokeColor: bg,
      pieOuterStrokeColor: border,
      pieOpacity: 1,
      relationLabelBackground: bg,
      commitLabelBackground: bg,
      commitLabelFontSize: `${size * 0.8}px`,
      tagLabelFontSize: `${size * 0.8}px`,
      branchLabelColor: onSolid,
      quadrantPointFill: border,
      xyChart: {
        backgroundColor: bg,
        titleColor: text,
        xAxisTitleColor: text,
        xAxisLabelColor: text,
        xAxisTickColor: border,
        xAxisLineColor: border,
        yAxisTitleColor: text,
        yAxisLabelColor: text,
        yAxisTickColor: border,
        yAxisLineColor: border,
        plotColorPalette: colours.map((c) => role(`series-${c}`)).join(","),
      },
    };
    for (let i = 0; i < 12; i++) {
      vars[`cScale${i}`] = solid[i % solid.length];
      vars[`cScaleInv${i}`] = solid[(i + 1) % solid.length];
      vars[`pie${i + 1}`] = solid[i % solid.length];
      if (i < 8) {
        vars[`git${i}`] = solid[i];
        vars[`gitInv${i}`] = solid[(i + 1) % 8];
      }
      if (i > 0 && i < 4) {
        vars[`quadrant${i + 1}Fill`] = fill;
        vars[`quadrant${i + 1}TextFill`] = text;
      }
    }
    return {
      fontFamily: family,
      fontSize: size,
      startOnLoad: false,
      themeCSS: labelStyles,
      theme: "base",
      themeVariables: vars,
      er: { fontSize: size },
      gantt: {
        fontSize: size,
        sectionFontSize: size,
      },
      journey: {
        taskFontSize: size,
        taskFontFamily: family,
      },
      xyChart: {
        titleFontSize: size * 1.1,
        xAxis: {
          labelFontSize: size,
          titleFontSize: size,
        },
        yAxis: {
          labelFontSize: size,
          titleFontSize: size,
        },
      },
      quadrantChart: {
        titleFontSize: size * 1.1,
        xAxisLabelFontSize: size,
        yAxisLabelFontSize: size,
        quadrantLabelFontSize: size * 0.8,
        pointLabelFontSize: size * 0.8,
      },
    };
  };

  const paintMermaid = (svg, size, { role, series: hues }) => {
    const type = svg.getAttribute("aria-roledescription");
    if (type === "class") {
      svg.querySelectorAll(".cluster rect").forEach((rect) => {
        if (rect.style.stroke === "black")
          rect.style.setProperty("stroke", role("node-border"), "important");
      });
    }
    if (type === "sankey") {
      const mapping = new Map();
      svg.querySelectorAll(".nodes .node rect").forEach((rect, i) => {
        const original = rect.getAttribute("fill");
        if (!mapping.has(original)) mapping.set(original, hues[i % hues.length]);
        rect.style.setProperty("fill", role(`series-${mapping.get(original)}`), "important");
      });
      svg.querySelectorAll("linearGradient stop").forEach((stop) => {
        const hue = mapping.get(stop.getAttribute("stop-color"));
        stop.setAttribute("stop-color", role(`flow-${hue}`));
      });
      svg.querySelectorAll(".node-labels text").forEach((text) => {
        const b = text.getBBox(),
          padding = size * 0.15;
        const plate = document.createElementNS(
          "http://www.w3.org/2000/svg",
          "rect",
        );
        plate.setAttribute("x", b.x - padding);
        plate.setAttribute("y", b.y - padding);
        plate.setAttribute("width", b.width + 2 * padding);
        plate.setAttribute("height", b.height + 2 * padding);
        plate.setAttribute("fill", role("label-background"));
        text.before(plate);
      });
      svg.appendChild(svg.querySelector(".node-labels"));
    }
  };

  const diagrams = [...document.querySelectorAll(".constellate-mermaid")];
  const fontSize = () => parseFloat(getComputedStyle(document.documentElement)
    .getPropertyValue("--constellate-diagram-font-size"));
  const fontFamily = () => getComputedStyle(document.documentElement)
    .getPropertyValue("--mermaid-font-family").trim();
  let serial = 0, running = false, pending = false;
  async function render() {
    const size = fontSize();
    const roles = diagramRoles();
    mermaid.initialize(mermaidConfig(size, fontFamily(), roles));
    for (const diagram of diagrams) {
      try {
        const source = diagram.dataset.source;
        const themedSource = mermaidSource(source, mermaid.detectType(source), roles);
        const result = await mermaid.render(`constellate-mermaid-${++serial}`, themedSource);
        diagram.innerHTML = result.svg;
        const svg = diagram.querySelector("svg");
        paintMermaid(svg, size, roles);
        if (diagram.hasAttribute("data-alt")) {
          const alt = diagram.dataset.alt;
          if (alt) {
            svg.setAttribute("role", "img");
            svg.setAttribute("aria-label", alt);
          } else svg.setAttribute("aria-hidden", "true");
        }
        result.bindFunctions?.(diagram);
      } catch (error) {
        console.error("Constellate Mermaid rendering failed", error);
      }
    }
    if (typeof Reveal !== "undefined") Reveal.layout();
  }
  async function refresh() {
    if (running) {
      pending = true;
      return;
    }
    running = true;
    try {
      do {
        pending = false;
        await render();
      } while (pending);
    } finally {
      running = false;
    }
  }
  async function start() {
    const font = `${fontSize()}px ${fontFamily()}`;
    const weight = getComputedStyle(document.documentElement)
      .getPropertyValue("--mermaid-font-weight").trim();
    const text = diagrams.map((diagram) => diagram.dataset.source).join("\n");
    await Promise.allSettled([...new Set(["400", "700", weight])].flatMap((weight) => [
      document.fonts.load(`${weight} ${font}`, text),
      document.fonts.load(`italic ${weight} ${font}`, text),
    ]));
    refresh();
    const alternate = document.querySelector("link#quarto-bootstrap.quarto-color-alternate");
    if (!alternate) return;
    let enabled = alternate.rel === "stylesheet";
    const changed = () => {
      const next = alternate.rel === "stylesheet";
      if (next === enabled) return;
      enabled = next;
      refresh();
    };
    alternate.addEventListener("load", () => {
      if (alternate.rel === "stylesheet") changed();
    });
    new MutationObserver(() => {
      if (alternate.rel !== "stylesheet") changed();
    }).observe(alternate, { attributes: true, attributeFilter: ["rel"] });
  }
  document.addEventListener("DOMContentLoaded", start);
})();
