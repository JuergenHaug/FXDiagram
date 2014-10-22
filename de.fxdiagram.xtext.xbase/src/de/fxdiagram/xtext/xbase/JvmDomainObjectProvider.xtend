package de.fxdiagram.xtext.xbase

import de.fxdiagram.annotations.properties.FxProperty
import de.fxdiagram.annotations.properties.ModelNode
import de.fxdiagram.xtext.glue.mapping.ESetting
import de.fxdiagram.xtext.glue.mapping.MappedElement
import de.fxdiagram.xtext.glue.mapping.XtextDomainObjectProvider
import de.fxdiagram.xtext.glue.mapping.XtextEObjectDescriptor
import de.fxdiagram.xtext.glue.mapping.XtextESettingDescriptor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.ui.JavaUI
import org.eclipse.xtext.common.types.JvmType
import org.eclipse.xtext.resource.IResourceServiceProvider

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*

class JvmDomainObjectProvider extends XtextDomainObjectProvider {
	
	protected def getJvmDomainUtil(URI uri) {
		val serviceLookupURI = if(uri.scheme == 'java')
				URI.createURI('dummy.___xbase')
			else
				uri
		val resourceServiceProvider = IResourceServiceProvider.Registry.INSTANCE
			.getResourceServiceProvider(serviceLookupURI)
		resourceServiceProvider.get(JvmDomainUtil)
	}
	
	override createDescriptor(Object handle) {
		if(handle instanceof MappedElement<?>) {
			switch it: handle.element {
				EObject: 
					return new JvmEObjectDescriptor(URI.toString, fullyQualifiedName, handle.mapping.config.ID, handle.mapping.ID, this)
				ESetting<?>:
					return new JvmESettingDescriptor(owner.URI.toString, owner.fullyQualifiedName, reference, index, handle.mapping.config.ID, handle.mapping.ID, this)
				IJavaElement: {
					val jvmType = getJvmDomainUtil(URI.createURI('dummy.___xbase')).getJvmType(it)					
					return new JavaElementDescriptor(jvmType.URI.toString, jvmType.fullyQualifiedName, handleIdentifier, handle.mapping.config.ID, handle.mapping.ID, this)
				}
				default:
					return null
			}
		}
		return null
	}
}

class JvmEObjectDescriptor<ECLASS extends EObject> extends XtextEObjectDescriptor<ECLASS> {

	new() {
	}

	new(String uri, String fqn, String mappingConfigID, String mappingID, JvmDomainObjectProvider provider) {
		super(uri, fqn, mappingConfigID, mappingID, provider)
	}
	
	override protected getResourceServiceProvider() {
		 IResourceServiceProvider.Registry.INSTANCE.getResourceServiceProvider(URI.createURI('dummy.___xbase'))
	}
}

@ModelNode
class JvmESettingDescriptor<ECLASS extends EObject> extends XtextESettingDescriptor<ECLASS> {

	new() {
	}

	new(String uri, String fqn, EReference reference, int index, String mappingConfigID, String mappingID, XtextDomainObjectProvider provider) {
		super(uri, fqn, reference, index, mappingConfigID, mappingID, provider)
	}
	
	override protected getResourceServiceProvider() {
		 IResourceServiceProvider.Registry.INSTANCE.getResourceServiceProvider(URI.createURI('dummy.___xbase'))
	}
}

@ModelNode('handleIdentifier')
class JavaElementDescriptor extends JvmEObjectDescriptor<JvmType> {

	@FxProperty(readOnly) String handleIdentifier

	new() {
	}

	new(String uri, String fqn, String javaElementHandle, String mappingConfigID, String mappingID, JvmDomainObjectProvider provider) {
		super(uri, fqn, mappingConfigID, mappingID, provider)
		handleIdentifierProperty.set(javaElementHandle)
	}
	
	override protected getResourceServiceProvider() {
		 IResourceServiceProvider.Registry.INSTANCE.getResourceServiceProvider(URI.createURI('dummy.___xbase'))
	}
	
	override <T> withDomainObject((JvmType)=>T lambda) {
		val javaElement = JavaCore.create(handleIdentifier)
		val domainUtil = (provider as JvmDomainObjectProvider).getJvmDomainUtil(URI.createURI(uri))
		val jvmType = domainUtil.getJvmType(javaElement)
		lambda.apply(jvmType)
	}

	override openInEditor(boolean isSelect) {
		val javaElement = JavaCore.create(handleIdentifier)
		JavaUI.openInEditor(javaElement, true, isSelect)
	}
}