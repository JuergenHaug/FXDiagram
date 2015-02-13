package de.fxdiagram.core.behavior

import de.fxdiagram.core.XShape
import de.fxdiagram.core.command.MoveCommand
import javafx.geometry.Point2D
import javafx.scene.input.MouseEvent
import org.eclipse.xtend.lib.annotations.Data

import static extension de.fxdiagram.core.extensions.CoreExtensions.*
import de.fxdiagram.annotations.properties.FxProperty

class MoveBehavior <T extends XShape> extends AbstractHostBehavior<T> {
	
	DragContext dragContext
	
	@FxProperty boolean isManuallyPlaced
	
	new(T host) {
		super(host)
	}
	
	override doActivate() {
		host.node.onMousePressed = [
			mousePressed  
		]
		host.node.onMouseDragged = [
			mouseDragged	
		]
		host.node.onMouseReleased = [
			if(dragContext != null) {
				if(dragContext.initialX != host.layoutX || dragContext.initialY != host.layoutY) {
					host.root.commandStack.execute(new MoveCommand(
						host,
						dragContext.initialX, dragContext.initialY,
						host.layoutX, host.layoutY
					))
					isManuallyPlaced = true
				}
			}
		]
	}
	
	override getBehaviorKey() {
		MoveBehavior
	}
	
	def mousePressed(MouseEvent it) {
		val initialPositionInScene = host.parent.localToScene(host.layoutX, host.layoutY)
		dragContext = new DragContext(
			host.layoutX,
			host.layoutY,
			screenX,
			screenY,
			initialPositionInScene
		)
	}
	
	def mouseDragged(MouseEvent it) {
		val newPositionInScene = new Point2D(
			dragContext.initialPosInScene.x + screenX - dragContext.mouseAnchorX,
			dragContext.initialPosInScene.y + screenY - dragContext.mouseAnchorY)
		val newPositionInDiagram = host.parent.sceneToLocal(newPositionInScene)
		if(newPositionInDiagram != null) {
			host.layoutX = newPositionInDiagram.x
			host.layoutY = newPositionInDiagram.y			
		}
	}
	
	@Data 
	static class DragContext {
		double initialX
		double initialY
		double mouseAnchorX 
		double mouseAnchorY
		Point2D initialPosInScene
	}
}
