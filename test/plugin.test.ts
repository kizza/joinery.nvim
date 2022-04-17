import assert from "assert";
import {getLines, populateBuffer} from "./helpers/buffer";
import {callLua, callVim} from "./helpers/call";
import {withVim} from "./helpers/vim";

describe("joinery", () => {
  it("loads the test vimrc", () =>
    withVim(async nvim => {
      const loaded = (await nvim.getVar("test_vimrc_loaded")) as boolean;
      assert.equal(loaded, true);
    }));

  describe("get_partitioned_ranges", () => {
    describe("without do_block", () => {
      it("returns a single range", () =>
        withVim(async nvim => {
          await populateBuffer(nvim, "|one.two", "ruby");
          const result = await callLua<number[][]>(nvim, "joinery", "get_partitioned_ranges()")
          assert.equal(result.toString(), [[1, 1, 1, 7]].toString())
        }));
    });

    describe("with do_block", () => {
      it("returns both ranges", () =>
        withVim(async nvim => {
          const lines = ["|one", "  .two do", "    foo", "  end"]
          await populateBuffer(nvim, lines, "ruby");
          const result = await callLua<number[][]>(nvim, "joinery", "get_partitioned_ranges()")
          assert.equal(result.toString(), [
            [1, 1, 2, 6], [2, 8, 4, 5]
          ].toString())
        }));
    });
  });

  describe("join", () => {
    it("joins within a scope", () =>
      withVim(async nvim => {
        const lines = ["one", "  .t|wo", "  .three"]
        const expected = "one.two.three"

        await populateBuffer(nvim, lines, "ruby");
        await nvim.command(`call joinery#toggle()`)
        assert.equal(await getLines(nvim), expected)
      }));

    it("resolves callable scope from nested cursor", () =>
      withVim(async nvim => {
        const lines = ["one", "  .two(foo: b|ar)", "  .three"]
        const expected = "one.two(foo: bar).three"

        await populateBuffer(nvim, lines, "ruby");
        await nvim.command(`call joinery#toggle()`)
        assert.equal(await getLines(nvim), expected)
      }));

    it("doesn't join 'block' ranges", () =>
      withVim(async nvim => {
        const lines = ["one", "  .|two do", "    something", "  end"]
        const expected = "one.two do\n  something\nend"

        await populateBuffer(nvim, lines, "ruby");
        await nvim.command(`call joinery#toggle()`)
        assert.equal(await getLines(nvim), expected)
      }));

    describe("split", () => {
      it("splits a line with arguments", () =>
        withVim(async nvim => {
          const lines = ["one.two.th|ree do", "  something", "end"]
          const expected = "one\n  .two\n  .three do\n    something\n  end"

          await populateBuffer(nvim, lines, "ruby");
          await nvim.command(`call joinery#toggle()`)
          assert.equal(await getLines(nvim), expected)
        }));

      it("skips delimeters nested in parenthesis", () =>
        withVim(async nvim => {
          const lines = ["one.two(foo.bar[foo.bar{foo.bar}]).th|ree do", "  something", "end"]
          const expected = "one\n  .two(foo.bar[foo.bar{foo.bar}])\n  .three do\n    something\n  end"

          await populateBuffer(nvim, lines, "ruby");
          await nvim.command(`call joinery#toggle()`)
          assert.equal(await getLines(nvim), expected)
        }));

      it("includes 'argument_list' as callable scope", () =>
        withVim(async nvim => {
          const lines = ["one.two{foo: :bar}.th|ree"]
          const expected = "one\n  .two{foo: :bar}\n  .three"

          await populateBuffer(nvim, lines, "ruby");
          await nvim.command(`call joinery#toggle()`)
          assert.equal(await getLines(nvim), expected)
        }));

      describe("respecting initial indentation", () => {
        it("respects indent with first char match", () =>
          withVim(async nvim => {
            const lines = ["  one.t|wo.three"]
            const expected = "  one\n    .two\n    .three"

            await populateBuffer(nvim, lines, "ruby");
            await nvim.command(`call joinery#toggle()`)
            assert.equal(await getLines(nvim), expected)
          }));

        it("respects indent with nested line match", () =>
          withVim(async nvim => {
            const lines = ["  foo = one.t|wo.three"]
            const expected = "  foo = one\n    .two\n    .three"

            await populateBuffer(nvim, lines, "ruby");
            await nvim.command(`call joinery#toggle()`)
            assert.equal(await getLines(nvim), expected)
          }));
      });
    });
  });
});
