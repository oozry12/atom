{Model} = require 'theorist'
PaneModel = require '../src/pane-model'
PaneAxisModel = require '../src/pane-axis-model'
PaneContainerModel = require '../src/pane-container-model'

describe "PaneModel", ->
  describe "split methods", ->
    [pane1, container] = []

    beforeEach ->
      pane1 = new PaneModel(items: ["A"])
      container = new PaneContainerModel(root: pane1)

    describe "::splitLeft(params)", ->
      describe "when the parent is the container root", ->
        it "replaces itself with a row and inserts a new pane to the left of itself", ->
          pane2 = pane1.splitLeft(items: ["B"])
          pane3 = pane1.splitLeft(items: ["C"])
          expect(container.root.orientation).toBe 'horizontal'
          expect(container.root.children).toEqual [pane2, pane3, pane1]

      describe "when the parent is a column", ->
        it "replaces itself with a row and inserts a new pane to the left of itself", ->
          pane1.splitDown()
          pane2 = pane1.splitLeft(items: ["B"])
          pane3 = pane1.splitLeft(items: ["C"])
          row = container.root.children[0]
          expect(row.orientation).toBe 'horizontal'
          expect(row.children).toEqual [pane2, pane3, pane1]

    describe "::splitRight(params)", ->
      describe "when the parent is the container root", ->
        it "replaces itself with a row and inserts a new pane to the right of itself", ->
          pane2 = pane1.splitRight(items: ["B"])
          pane3 = pane1.splitRight(items: ["C"])
          expect(container.root.orientation).toBe 'horizontal'
          expect(container.root.children).toEqual [pane1, pane3, pane2]

      describe "when the parent is a column", ->
        it "replaces itself with a row and inserts a new pane to the right of itself", ->
          pane1.splitDown()
          pane2 = pane1.splitRight(items: ["B"])
          pane3 = pane1.splitRight(items: ["C"])
          row = container.root.children[0]
          expect(row.orientation).toBe 'horizontal'
          expect(row.children).toEqual [pane1, pane3, pane2]

    describe "::splitUp(params)", ->
      describe "when the parent is the container root", ->
        it "replaces itself with a column and inserts a new pane above itself", ->
          pane2 = pane1.splitUp(items: ["B"])
          pane3 = pane1.splitUp(items: ["C"])
          expect(container.root.orientation).toBe 'vertical'
          expect(container.root.children).toEqual [pane2, pane3, pane1]

      describe "when the parent is a row", ->
        it "replaces itself with a column and inserts a new pane above itself", ->
          pane1.splitRight()
          pane2 = pane1.splitUp(items: ["B"])
          pane3 = pane1.splitUp(items: ["C"])
          column = container.root.children[0]
          expect(column.orientation).toBe 'vertical'
          expect(column.children).toEqual [pane2, pane3, pane1]

    describe "::splitDown(params)", ->
      describe "when the parent is the container root", ->
        it "replaces itself with a column and inserts a new pane below itself", ->
          pane2 = pane1.splitDown(items: ["B"])
          pane3 = pane1.splitDown(items: ["C"])
          expect(container.root.orientation).toBe 'vertical'
          expect(container.root.children).toEqual [pane1, pane3, pane2]

      describe "when the parent is a row", ->
        it "replaces itself with a column and inserts a new pane below itself", ->
          pane1.splitRight()
          pane2 = pane1.splitDown(items: ["B"])
          pane3 = pane1.splitDown(items: ["C"])
          column = container.root.children[0]
          expect(column.orientation).toBe 'vertical'
          expect(column.children).toEqual [pane1, pane3, pane2]

    it "sets up the new pane to be focused", ->
      expect(pane1.focused).toBe false
      pane2 = pane1.splitRight()
      expect(pane2.focused).toBe true

  describe "::destroyItem(item)", ->
    describe "when the last item is destroyed", ->
      it "destroys the pane", ->
        pane = new PaneModel(items: ["A", "B"])
        pane.destroyItem("A")
        pane.destroyItem("B")
        expect(pane.isDestroyed()).toBe true

  describe "when an item emits a destroyed event", ->
    it "removes it from the list of items", ->
      pane = new PaneModel(items: [new Model, new Model, new Model])
      [item1, item2, item3] = pane.items
      pane.items[1].destroy()
      expect(pane.items).toEqual [item1, item3]

  describe "::destroy()", ->
    [pane1, container] = []

    beforeEach ->
      pane1 = new PaneModel(items: [new Model, new Model])
      container = new PaneContainerModel(root: pane1)

    it "destroys the pane's destroyable items", ->
      [item1, item2] = pane1.items
      pane1.destroy()
      expect(item1.isDestroyed()).toBe true
      expect(item2.isDestroyed()).toBe true

    describe "if the pane's parent has more than two children", ->
      it "removes the pane from its parent", ->
        pane2 = pane1.splitRight()
        pane3 = pane2.splitRight()

        expect(container.root.children).toEqual [pane1, pane2, pane3]
        pane2.destroy()
        expect(container.root.children).toEqual [pane1, pane3]

    describe "if the pane's parent has two children", ->
      it "replaces the parent with its last remaining child", ->
        pane2 = pane1.splitRight()
        pane3 = pane2.splitDown()

        expect(container.root.children[0]).toBe pane1
        expect(container.root.children[1].children).toEqual [pane2, pane3]
        pane3.destroy()
        expect(container.root.children).toEqual [pane1, pane2]
        pane2.destroy()
        expect(container.root).toBe pane1