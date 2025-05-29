{outputs, ...}: let
  css = ''
    .cm-contentContainer {
      line-height: 1.5;
    }
    /* .mod-fade:not(.mod-at-end):after { */
    /* background-color:  */
    /* } */
    * {
      --background-primary: ${outputs.palette.base00} !important;
      --background-secondary: ${outputs.palette.base01} !important;
      --ribbon-background: ${outputs.palette.base00} !important;

      --titlebar-background: ${outputs.palette.base01} !important;
      --titlebar-background-focused: ${outputs.palette.base00} !important;
    }
    .mod-fade:not(.mod-at-end):after {
      background: linear-gradient(
        to right,
        transparent,
        rgba(0, 0, 0, 0)
      ) !important;
    }

    /* author: https://forum.obsidian.md/u/rsdimitrov */
    /* source: https://forum.obsidian.md/t/optimize-obsidian-ui-for-a-more-seamless-experience/155/5 */
    .view-header:not(:hover) .view-actions {
      opacity: 0.1;
      transition: opacity 0.25s ease-in-out;
    }

    /* auto fades status bar items */
    .status-bar:not(:hover) .status-bar-item {
      opacity: 0.25;
      transition: opacity 0.25s ease-in-out;
    }

    /* author: https://forum.obsidian.md/u/Thery/summary */
    /* source: https://forum.obsidian.md/t/meta-post-common-css-hacks/1978/39 */

    blockquote:before {
      font:
        14px/20px italic Times,
        serif;
      content: "“";
      font-size: 5em;
      line-height: 0.1em;
      vertical-align: -0.4em;
    }
    blockquote p {
      display: inline;
    }

    /* Remove blockquote left margin */
    blockquote {
      margin-inline-start: 0;
    }

    /* author: https://github.com/cannibalox & https://github.com/konhi */
    /* source: https://forum.obsidian.md/t/meta-post-common-css-hacks/1978/82 */

    .popover.hover-popover {
      transform: scale(0.8); /* makes the content smaller */
      max-height: 800px; /* was 300 */
      min-height: 100px;
      width: 500px; /* was 400 */
    }

    .popover.hover-popover .markdown-embed {
      height: 800px;
    }

    /* author: https://forum.obsidian.md/u/uzerper */
    /* source: https://forum.obsidian.md/t/meta-post-common-css-hacks/1978/72 */

    .tag:not(.token) {
      background-color: var(--text-accent);
      border: none;
      color: ${outputs.palette.base00};
      font-size: 13px;
      padding: 1px 8px;
      text-align: center;
      text-decoration: none;
      display: inline-block;
      margin: 0px 0px;
      cursor: pointer;
      border-radius: 1px;
    }
    .tag:not(.token):hover {
      color: ${outputs.palette.base00};
      background-color: var(--text-accent-hover);
    }
    .tag[href^="#obsidian"] {
      background-color: #4d3ca6;
    }
    .tag[href^="#important"] {
      background-color: ${outputs.palette.base08};
    }
    .tag[href^="#complete"] {
      background-color: ${outputs.palette.base0B};
    }
    .tag[href^="#inprogress"] {
      background-color: ${outputs.palette.base09}
    }

    /* Custom icons for specific folders or files */

    :root {
      --active-file-bg-color: ${outputs.palette.base0B};
      --active-file-fg-color: ${outputs.palette.base00};
    }

    /* folder begin */
    .nav-folder-title {
      cursor: pointer !important;
    }
    .nav-file-title-content,
    .nav-folder-title-content {
      display: flex !important;
      align-items: center;
    }
    .nav-folder-title-content::before {
      content: "";
      background: url("https://media.macosicons.com/parse/files/macOSicons/af21153d07a2e92bde7b2ad155055489_low_res_1619092574091.png")
        no-repeat center;
      background-size: 100%;
      width: 20px;
      height: 20px;
      display: inline-block;
      margin-right: 5px;
    }
    /* root folder */
    div[data-path="/"] .nav-folder-title-content::before {
      content: "";
    }
    /* 所有的附件目录, 我自定义的附件目录为笔记所在目录的名为 attachments 的子目录, 匹配以 attachments 结尾 */
    /* All attachment directories, and my custom `attachments` directory is the subdirectory named `attachments` of the note directory and ends with the matching `attachments` */
    div[data-path$="attachments"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/325fcaee7fcf0ce428cddec2a53675c1_low_res_Folder___Favourite_Images.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/c84880ed4b36bcaf78df9580aa069a43_low_res_Programming_Folder.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程/工具"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/9d1f67b889d73ed9813c83199e039354_low_res_Developer_Folder.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程/Docker"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/f024d0e956f6663fb48b55ac11673f54_low_res_Docker.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程/MacOS"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/4ad8d9253a2541e49b6d86d5fe0f6829_low_res_Apple.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程/MySQL"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/dfb95bab582395d9e5fa89284bb24e34_MySQL_Workbench.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程/RabbitMQ"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/28c81b354a89b7ebeb599a849f5291a2_low_res_Matrix_Follow_the_White_Rabbit_Folder.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程/Spring"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/d89876a20a9ce438cc7f437a7704a6a2_low_res_Spring_Tool_Suite_4.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程/Linux"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/6604c58f3ffcd4648f6c1bf1a956818b_low_res_Linux.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程/Jenkins"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/c5e3a3b55e2e23b9dc839305fe53dbf1_low_res_Jenkins.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程/Java"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/f4ae1a3f1d2143a2e2ec0b94ea374ace_low_res_Java.png")
        no-repeat center;
      background-size: 100%;
    }
    div[data-path="编程/GitLab"] .nav-folder-title-content::before {
      background: url("https://media.macosicons.com/parse/files/macOSicons/d7033bb681a9f5ae6f3b0479573b0352_low_res_Gitlab.png")
        no-repeat center;
      background-size: 100%;
    }
    /* folder end */

    /* file begin */
    .nav-file-title {
      cursor: pointer !important;
    }
    .nav-file-title-content::before {
      content: "";
      background: url("https://media.macosicons.com/parse/files/macOSicons/c66c64dea9d84b6dcb21836d5fa451e5_low_res_Google_Docs.png")
        no-repeat center;
      background-size: 100%;
      width: 20px;
      height: 20px;
      display: inline-block;
      margin-right: 5px;
    }
    /* All attachment hidden file icon */
    .nav-file-title[data-path*="attachments"] .nav-file-title-content::before {
      content: "";
      background: none !important;
      width: 0px;
      height: 0px;
      display: inline-block;
      margin-right: 0px;
    }
    body:not(.is-grabbing) .nav-file-title.is-active:hover,
    body:not(.is-grabbing) .nav-folder-title.is-active:hover,
    .nav-file-title.is-active,
    .nav-folder-title.is-active {
      background: var(--active-file-bg-color) !important;
      color: var(--active-file-fg-color) !important;
    }
    /* file end */

    /* author: https://forum.obsidian.md/u/rsdimitrov */
    /* source: https://forum.obsidian.md/t/optimize-obsidian-ui-for-a-more-seamless-experience/155/5 */

    /* smaller scrollbar */
    .CodeMirror-vscrollbar,
    .CodeMirror-hscrollbar,
    ::-webkit-scrollbar {
      width: 3px;
    }

    /* author: https://forum.obsidian.md/u/den/summary */
    /* source: https://forum.obsidian.md/t/meta-post-common-css-hacks/1978/29 */

    .markdown-preview-view img {
      display: block;
      margin-top: 20pt;
      margin-bottom: 20pt;
      margin-left: auto;
      margin-right: auto;
      width: 50%; /* experiment with values */
      transition: transform 0.25s ease;
    }

    .markdown-preview-view img:hover {
      -webkit-transform: scale(1.8); /* experiment with values */
      transform: scale(2);
    }

    :root {
      --base00: ${outputs.palette.base00};
      --base01: ${outputs.palette.base01};
      --base02: ${outputs.palette.base02};
      --base03: ${outputs.palette.base03};
      --base04: ${outputs.palette.base04};
      --base05: ${outputs.palette.base05};
      --base06: ${outputs.palette.base06};
      --base07: ${outputs.palette.base07};
      --base08: ${outputs.palette.base08};
      --base09: ${outputs.palette.base09};
      --base0A: ${outputs.palette.base0A};
      --base0B: ${outputs.palette.base0B};
      --base0C: ${outputs.palette.base0C};
      --base0D: ${outputs.palette.base0D};
      --base0E: ${outputs.palette.base0E};
      --base0F: ${outputs.palette.base0F};
    }

    /*************************
     * Font selection
    *************************/

    .workspace {
      font-family: var(--font-family-editor);
    }

    .markdown-preview-view {
      font-family: var(--font-family-preview) !important;
    }

    /*************************
     * workspace
    *************************/

    .workspace {
      color: var(--base06) !important;
      background-color: var(--base00) !important;
    }

    .workspace-tabs {
      color: var(--base06) !important;
      background-color: var(--base00) !important;
    }

    .workspace-tab-header {
      color: var(--base06) !important;
      background-color: var(--base00) !important;
    }

    .workspace-tab-header-inner {
      color: var(--base02) !important;
    }

    .workspace-leaf {
      color: var(--base06) !important;
      background-color: var(--base00) !important;
    }

    /*************************
     * View header
    *************************/

    .view-header {
      background-color: var(--base00) !important;
      color: var(--base06) !important;
      border-bottom: 1px solid var(--base01);
    }

    .view-header-title {
      color: var(--base06) !important;
    }

    .view-header-title-container:after {
      background: none !important;
    }

    .view-content {
      background-color: var(--base00) !important;
      color: var(--base06) !important;
    }

    .view-action {
      color: var(--base06) !important;
    }

    /*************************
     * Nav folder
    *************************/

    .nav-folder-title, .nav-file-title {
      background-color: var(--base00) !important;
      color: var(--base06) !important;
    }

    .nav-action-button {
      color: var(--base06) !important;
    }

    /*************************
     * Markdown headers
    *************************/

    .cm-header-1, .markdown-preview-view h1 {
      color: var(--base0A);
    }

    .cm-header-2, .markdown-preview-view h2 {
      color: var(--base0B);
    }

    .cm-header-3, .markdown-preview-view h3 {
      color: var(--base0C);
    }

    .cm-header-4, .markdown-preview-view h4 {
      color: var(--base0D);
    }

    .cm-header-5, .markdown-preview-view h5 {
      color: var(--base0E);
    }

    .cm-header-6, .markdown-preview-view h6 {
      color: var(--base0E);
    }

    /*************************
     * Markdown strong and emphasis
    *************************/

    .cm-em, .markdown-preview-view em {
      color: var(--base0D);
    }

    .cm-strong, .markdown-preview-view strong {
      color: var(--base09);
    }

    /*************************
     * Markdown links
    *************************/

    .cm-link, .markdown-preview-view a {
      color: var(--base0C) !important;
    }

    .cm-formatting-link,.cm-url {
      color: var(--base03) !important;
    }

    /*************************
     * Quotes
    *************************/

    .cm-quote, .markdown-preview-view blockquote {
      color: var(--base0D) !important;
    }

    /*************************
     * Code blocks
    *************************/

    .HyperMD-codeblock, .markdown-preview-view pre {
      color: var(--base07) !important;
      background-color: var(--base01) !important;
    }

    .cm-inline-code, .markdown-preview-view code {
      color: var(--base07) !important;
      background-color: var(--base01) !important;
    }

    /*************************
     * Cursor
    *************************/

    .CodeMirror-cursors {
      color: var(--base0B);
      z-index: 5 !important /* fixes a bug where cursor is hidden in code blocks */
    }
  '';
in
  css
