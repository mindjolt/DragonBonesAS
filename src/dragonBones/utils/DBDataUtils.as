package dragonBones.utils
{
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.ArmatureData;
	import dragonBones.objects.BoneData;
	import dragonBones.objects.DBTransform;
	import dragonBones.objects.Frame;
	import dragonBones.objects.SkinData;
	import dragonBones.objects.SlotData;
	import dragonBones.objects.TransformFrame;
	import dragonBones.objects.TransformTimeline;
	import dragonBones.utils.ConstValues;
	
	import flash.geom.Point;
	
	public final class DBDataUtils
	{
		private static var _helpTransform1:DBTransform = new DBTransform();
		private static var _helpTransform2:DBTransform = new DBTransform();
		
		public static function transformArmatureData(armatureData:ArmatureData):void
		{
			var i:int = armatureData.boneDataList.length;
			while(i --)
			{
				var boneData:BoneData = armatureData.boneDataList[i];
				if(boneData.parent)
				{
					var parentBoneData:BoneData = armatureData.getBoneData(boneData.parent);
					if(parentBoneData)
					{
						TransformUtils.transformPointWithParent(boneData.transform, parentBoneData.global);
					}
				}
			}
		}
		
		public static function transformAnimationData(animationData:AnimationData, armatureData:ArmatureData):void
		{
			var skinData:SkinData = armatureData.getSkinData(null);
			var i:int = armatureData.boneDataList.length;
			
			while(i --)
			{
				var boneData:BoneData = armatureData.boneDataList[i];
				var timeline:TransformTimeline = animationData.getTimeline(boneData.name);
				if(!timeline)
				{
					continue;
				}
				
				var slotData:SlotData = skinData.getSlotData(boneData.name);
				
				if(boneData.parent)
				{
					var parentTimeline:TransformTimeline = animationData.getTimeline(boneData.parent);
				}
				else
				{
					parentTimeline = null;
				}
				
				var frameList:Vector.<Frame> = timeline.frameList;
				
				var originTransform:DBTransform = null;
				var originPivot:Point = null;
				var length:uint = frameList.length;
				for(var j:int = 0;j < length;j ++)
				{
					var frame:TransformFrame = frameList[j] as TransformFrame;
					if(parentTimeline)
					{
						//tweenValues to transform.
						_helpTransform1.copy(frame.global);
						
						//get transform from parent timeline.
						getTimelineTransform(parentTimeline, frame.position, _helpTransform2);
						TransformUtils.transformPointWithParent(_helpTransform1, _helpTransform2);
						
						//transform to tweenValues.
						frame.transform.copy(_helpTransform1);
					}
					
					frame.transform.x -= boneData.transform.x;
					frame.transform.y -= boneData.transform.y;
					frame.transform.skewX -= boneData.transform.skewX;
					frame.transform.skewY -= boneData.transform.skewY;
					frame.transform.scaleX -= boneData.transform.scaleX;
					frame.transform.scaleY -= boneData.transform.scaleY;
					frame.pivot.x -= boneData.pivot.x;
					frame.pivot.y -= boneData.pivot.y;
					
					if(!originTransform)
					{
						originTransform = timeline.originTransform;
						originTransform.copy(frame.transform);
						originTransform.skewX = TransformUtils.formatRadian(originTransform.skewX);
						originTransform.skewY = TransformUtils.formatRadian(originTransform.skewY);
						originPivot = timeline.originPivot;
						originPivot.x = frame.pivot.x;
						originPivot.y = frame.pivot.y;
					}
					
					frame.transform.x -= originTransform.x;
					frame.transform.y -= originTransform.y;
					frame.transform.skewX -= originTransform.skewX;
					frame.transform.skewY -= originTransform.skewY;
					frame.transform.scaleX -= originTransform.scaleX;
					frame.transform.scaleY -= originTransform.scaleY;
					frame.pivot.x -= originPivot.x;
					frame.pivot.y -= originPivot.y;
					
					frame.transform.skewX = TransformUtils.formatRadian(frame.transform.skewX);
					frame.transform.skewY = TransformUtils.formatRadian(frame.transform.skewY);
					
					frame.zOrder -= slotData.zOrder;
				}
			}
		}
		
		public static function getTimelineTransform(timeline:TransformTimeline, position:Number, retult:DBTransform):void
		{
			var frameList:Vector.<Frame> = timeline.frameList;
			var i:int = frameList.length;
			while(i --)
			{
				var frame:TransformFrame = frameList[i] as TransformFrame;
				if(frame.position <= position && frame.position + frame.duration > position)
				{
					var progress:Number = (position - frame.position) / frame.duration;
					var index:Number = frameList.indexOf(frame);
					if(index == frameList.length - 1)
					{
						retult.copy(frame.global);
					}
					else
					{
						//var nextFrame:BoneFrame = timeline.frameList[index + 1] as BoneFrame;
						//AnimationState.setOffsetTransform(boneFrame, nextFrame, retult);
						//TransformUtils.setTweenNode(boneFrame.transformGlobal, retult, retult, progress);
						retult.copy(frame.global);
					}
				}
			}
		}
		
		public static function addHideTimeline(animationData:AnimationData, armatureData:ArmatureData):void
		{
			var boneDataList:Vector.<BoneData> =armatureData.boneDataList;
			var i:int = boneDataList.length;
			while(i --)
			{
				var boneData:BoneData = boneDataList[i];
				var boneName:String = boneData.name;
				if(!animationData.getTimeline(boneName))
				{
					animationData.addTimeline(TransformTimeline.HIDE_TIMELINE, boneName);
				}
			}
		}
	}
}