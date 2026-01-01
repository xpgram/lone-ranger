class_name HeartContainerUI
extends Control


## How full the heart container should be. [br]
## 0 = empty. [br]
## 1 = half full. [br]
## 2 = full. [br]
@export var fill_value := 2:
  set(value):
    fill_value = clampi(value, 0, 2);
