# cl-gpio

Common Lisp library to control GPIO pins in Raspberry PI and Orange Pi Plus.

## Raspberry PI
    (gpio:cfg-pins '((:gpio12 :direction :out)
	                 (:gpio19 :direction :in)))
	(gpio:write-pin :gpio12 1)
    (gpio:read-pin :gpio19)

## Orange Pi Plus
    (gpio:cfg-pins '((:pg7 :direction :out)
	                 (:pg8 :direction :in)))
	(gpio:write-pin :pg7 1)
    (gpio:read-pin :pg8)
	(gpio:write-pin :|normal_led| 1)


