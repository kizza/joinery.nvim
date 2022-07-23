import assert from "assert";
import {getBuffer, setBuffer, vimRunner} from "nvim-test-js";
import * as path from "path";

const withVim = vimRunner(
  {vimrc: path.resolve(__dirname, "helpers", "vimrc.vim")}
)

describe("javascript", () => {
  describe("join", () => {
    it("joins within a scope", () =>
      withVim(async nvim => {
        const lines = ["one", "  .t|wo", "  .three"]
        const expected = "one.two.three"

        await setBuffer(nvim, lines, "javascript");
        const logs = await nvim.commandOutput(`call joinery#toggle()`)
        console.log(logs)
        assert.equal(await getBuffer(nvim), expected)
      }));
  });
});
