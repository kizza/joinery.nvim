import assert from "assert";
import {populateBuffer} from "./helpers/buffer";
import {callVim} from "./helpers/call";
import {withVim} from "./helpers/vim";

describe("util", () => {
  describe("within_brackets", () => {
    ["foo(ba|r)baz", "(|)foo", "foo(|)", "foo(|)baz", "foo[|]baz", "foo{|}baz", "foo([{|}])"].forEach((example) =>
      it(`is true for ${example}`, () =>
        withVim(async nvim => {
          await populateBuffer(nvim, [example], "ruby");
          const [_, line, column, __] = await callVim<string[]>(nvim, `getpos(".")`)
          const result = await callVim<boolean>(nvim, `joinery#util#is_within_line_brackets(${line}, ${column})`)
          assert.equal(result, true);
        })));

    it("is false when false", () =>
      withVim(async nvim => {
        await populateBuffer(nvim, ["foo b|ar baz"], "ruby");
        const [_, line, column, __] = await callVim<string[]>(nvim, `getpos(".")`)
        const result = await callVim<boolean>(nvim, `joinery#util#is_within_line_brackets(${line}, ${column})`)
        assert.equal(result, false);
      }));
  });

  describe("merge_ranges", () => {
    it("works with different start lines", () =>
      withVim(async nvim => {
        const result = await nvim.commandOutput(
          `echo luaeval("{require'joinery.ranges'.merge_ranges({0,0,1,2},{1,1,2,4})}")`
        )
        assert.equal(result, "[0, 0, 2, 4]");
      }));

    it("works with same start lines", () =>
      withVim(async nvim => {
        const result = await nvim.commandOutput(
          `echo luaeval("{require'joinery.ranges'.merge_ranges({8,4,8,11},{8,11,10,5})}")`
        )
        assert.equal(result, "[8, 4, 10, 5]");
      }));
  });
});
