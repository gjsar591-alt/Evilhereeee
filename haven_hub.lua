(function()
  if not game:IsLoaded() then game.Loaded:Wait() end

  local Services = setmetatable({}, {
    __index = function(self, k)
      local s = game:GetService(k)
      rawset(self, k, s)
      return s
    end
  })
  getgenv().Services = Services

  local Players = Services.Players
  local LocalPlayer = Players.LocalPlayer
  local TweenService = Services.TweenService
  local RunService = Services.RunService
  local HttpService = Services.HttpService
  local UserInputService = Services.UserInputService
  local ReplicatedStorage = Services.ReplicatedStorage

  -- ============================================================================
  -- 0. شاشة التحميل (HAVEN HUB LOADING SCREEN)
  -- ============================================================================
  local Loader = (function()
    local L = {Progress = 0, Target = 0, Done = false}
    local LOGO_B64 = "iVBORw0KGgoAAAANSUhEUgAAAUAAAAFACAMAAAD6TlWYAAABgFBMVEUAAAD29vjq6u8QBQi1CRjLDBuQBRPuJTPlFiUuBw1OBw9vBhH3NEIVBgoUBQkTBQkSBAcTBQkUBQnaEB4zJirSFiSsqKvOJzNRR0okFhrroqhwZ2vKyMvX1dixGSW4tbiNh4rhEB9uExualJhDNzvqlJrLR1K0JjJ7c3fiDR3qnKLYh45TEhjrh4+QGiPRZ3DclZrqZnBcU1Y9MjXQWmPOOUVJPUFiWFzWc3vd3OHxMD4rHSGNEx2inaLWe4LoeoN0GSGBen2zEB3KUlweEBTdnKHoR1PqdHxmXWGEfYHeoKW9OUXAvcHoWGOaISq+u8AoAAChnJ7AvL4jFRrOMT3g3uK7Mj41KzLjUl3h3t8rJCRENjaRkZG+QEv///8TExMdERUfHiEfICMmGRk8MDxOTk5tbW1/f3+/v78AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAN8shQAAAAgHRSTlMA/v79/v/+///+/v7/zo5PLm+v//3+/v/+/f/+/v7+/v7//f7+///+/v////z//f////7+///+/v////3+/v///v7///z////+/v/////+/wb//zL///8Z//8mEgf/AQ08//8UFQ0HCAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEWQJyQAABkFSURBVHja7Z0HV9vKtsdjj1xkI0sWrtjYYNMCxEmoAQIkkBBy0k+Sc/u9r7/3/T/Bm6JRsVVHMzLOmv/KWvesXGKj3+ymrT2aR4+kpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSkpKSk0siomxow5/C9ek0DmrHo8OBFYNWzh4dV+xXgNTpZAnTgXcDvNRcUnn0RjYNxP9cCQM/4e7udtd9zq1lbvgh4SD0AsoaXR9/7LauFE+E+B2sEHlIHaIK/2AXv9TBPvzeThRMSe1zwoPJdoaHI/t43JzsOPKQN4QsnBp7nIqD62JNgUjEEwtuYgkcWroZ/twfux+7YMwMPaQyrCRP/jJEZPGvhTPIz+kLA+93vIqxQBDhXg3rNtOG1gr53zf7e2uLCQzq0L0TnCg+EwEM65b9wIuC9D4WHQpF9Helzol53wVsN/95cg+/CCS4ZgjW0r0PjBa/X+kv0965yXLi5waOhSFXRP2IvZgw3vNV43zu0v1d7KPCsi+iexIaHdADUYlFlD0UOvMPY8JDeA1AtVh5MDjEDitVoNRBAwFrF1JjgkfufdAvHV1pEyRAaiirFKmsoMtng0YWrAu7lJ6P7AnAaJ3D7qGV7EkMoMgA4YYGXeuF4CzpSPsemHQRQZQxFcOGGjN+bauEERMAG43WkC0Vw4VbnsXDcBcAB43XAO/oUoSjFwp3YC/cAymgYitYYr6OfKhTB0Mu+cJUHlUNYQ9HYDkXmvBbu60PIIV3WHNKzPYkhFNUB+H0eCyegCjxkDUUbaUKRmIWr63PIIb25hCINbLAu3KF9/6PPZnY9+xwyZryOIQpFzNUY+8L9BIELpx02si5sYCjqM17IWppQBHPXN/aFCyij/wTWTrV/Zl1GM4ei0zRltJCF00F/DP6UdQ7psIaiRmAoirVwF6zfG9xDqwFY4uhZ55AdxutId0fPZeGmQ6B5kst1sw2CMBS15nFHb4hYuL+hz+xoWecQ1jv61ylbMfwXTkef+T7bIPhLtWLqqC83zDYIauytmIs5tWKCF87cwOV9lkFwjq2YFAsXUEb/NynNO2a2OYS1FXM5/1bM1If+Gwmrr8F/ZdrOZw1FPQCK82jnB7di6uTRxBB8zzIEMoeilK2YN/nUC+cNgX//q9awxk1qf/2/7Mro+0VrxTgLp9XqOvnu//2O9luA1zTLwP9L//7Ph51DPtqhSPvKsnAcemjWUI6JBxTdYyH98X0D8/3+91+0FcOlh6ZWKxVrjtDn4fzqZQ9BNOuG2ByywK2YSrlcBY2wQajV1k7nQujwR4pQxNyKMepokInDwhXLyyq4D0/m+VZH6HMT9lDE1IrR7Q1OPFoxSnldUcl0zV/87Q85MTAF+jCsxi65d4WD7M6k7NTKiEsrprC+vL6+rFRVnxGl1TGBV9f/84HmkPexc8hXZ58EUEcvB81SacCjFaMWlguFwnq5XG5SiNbFtA4IvO9/y6AVwxqKYrZidNvw1MrLQbtENOLRQ6uWMcECptiEECs0LnSxY2TRkxHSFXbDs3120iy5VOHRiqkqkByUBbHwuFz99zy5WS4qyEbF7yc27NqdeyvGHhlW9ye24VGVVeaFyzuTlWhIulItQoyPHxOERRKQxuCmUMAIRfe1BLXz7blndcrwqJpcWjG2IEUIEQK8IR97oGLXRnYq2AgFdIXd8NqlAE3YWzHfXAtnOFWRWoEMC00V9xgbFSs2VkWPUPMe0KPZNgwedOA0OWS2h0ZzvFpVypX/wIVOkYZFVCaKJMhzQI+aHox5IfBoDuE8zmR9ebWKguA3FAIpwYrIQMivK0xNrzIaRMFrDkYVEZOVBvkVxshIlwuORBKs8+kKU9MbDdpR7F5WVBKzWBfud6eH5pMTNbwydgi0CdaF5RAOA3pWIpxsR8CbjCg8VFl/FNNDq8OgvgqqhcIUQUNUGZ1uQE8FsaIeclrrR7Ua6s4J7KHVQb4FFC/AgipqL0SKVowTikbb7ciIRwzPnh3VwAn/yUqi76D12knCJI8UFEFhMF1XmN7RB8NrD0Yew8uih/Y/2v0JmDJBBdWDhpgckr4rPAqEV6HwdGPm/od1sjJ6nAkntMq0CapCmqopJiudAb2JDz03vKx7aAbQ6l4TVIgJPtRWzHTybU/21RB4GfTQ/gUvzJ2HFQWbYF1ECEzfFVbbXtNTA9zW3V/V0rVioncn14DqxocIVgUkYi6tmIrL9Cx6Uc8RBfbQ7CtTFQ8/pVAU4MNcWjGjGdObVw/Nu0SKhx+Uyn9okMuA3sBVrZh10QvXizcSSwEqihsg91IQ8JisHAz21bimx3Ph9Dgu7OIH7+dM/jmEV1c42fREqt3JscaZ6iiJKB4JyCJcBvQS08tkJNaElbQyC/Drg8khTleY4dFhXfzuZPjr+QDknYbnsMnV0PEcWvdn6h5aLSoEKopwF2afrDxLPllpOM/XgfCF02Y9GCURjXsOyWSTq+vJGXlpcm/MeiO8CmItnO7jwYrCPQvXhXWF3ehML7oha9RNMs7kZ4AC6kChm1zRBKBjdo2T3tpwNZ9Lq3gLV/M1QIX7RvYUXeGwyUorT1jqbtyvtfrp0U330OqhocnPAIvcW6rcu8Jeq+tunHJEl2AkVvNJwTgEcs4hKSYrZ+7op9AdHrzmjS5+GR3gwPxDYIqu8GsnFHnRgcbBzmX/Z06Q4rRi6v4OjDxY551DOHSFeaZY9nEmbwD0dWA04PFg2vn5BvwtPei4pFge7XzMz88A+Xtwuq5w1uime2hGoFX4B0CF/2PNFF3hMSnsWtmhi5tDAvkJeKqZohXzMXN0MVsxkF/Vn5+A5+opusLzUtTu5GB+Ih6rsw/ozU0RrZgQfgIMUGfvCs9LET20EH5F7i8ZNNDrr4cLBjC0h2aE8ONfA+K3h3d/LhS+fGgrRge+/Aa3A+LAXKc66uQl/huLFgJDemjokvzql6crH7AD82wjoCliMGmroJfLLxbARtg7K1U/flsrL4gDGzyrFwBG7aVt9nb+vBQ8WWkG3L9tP9sbcHZgZOr77aWlpQl7K2ZeCmrFoPRR8Usdg71nH/hmYOS96vYS0j57K2ZeOSSgFVMHQen3xcotLqF5ZWADee+rc8xviX2v5Nzk34oxA8IfTCC/PSX8DM7ei9RGk5ULZoJ+x4cg9w1oX93+dnWDEwifAIi/6bOF7xzlkNaCAfRrxWD39a+dt95aCaTGrXKm3ov0ir0VM68Q+G02hwS7L+K3jfmZ3JJH28HX3geLl0NmWjHo5qPi777Kh2fPtvlV0Mj8Jl58aEBvwcro6VaMCYJvfrnyQ+a375hfe4ScALViFgvgVCtGD84emN8fmB+PBIzM77ONr/QKT/Thycr8Qnnw0JNDasHZA8Y/jvymzG+C3sFQx68+XLQc4m7FoOgXlD1o/ihyOSrIa37bKi1CU0xWzgug04rB817VIPdVjvjxMzzmh3NHzZmKWdhWDAiJfuj+A9V/XPy37k6+569c7zDDk5WLFQJX3bsCgs1v8OK3F6R+Ts/PdNd+n1X3NDierFwsgC27nR9Y+6H+1R6+/+XBD2WPVx7vrXOZrJwXwPe0jA5OHqh8eXtL+KV+WxFy322399amJyvziwWwA1T0ejs12HsV5fbts3+QBrTGwX3t7LE9+/qoRcsh+Xy+EeW9ygCmj23SvzI5ZN9XAd5rT1bmFwgfft8yCoLB+HD4Q+lXTd9/0V3uO/F7BlhD7fz84rhvLr/WxcEvhB+8+7DCX+r+X83Jvu2K704sPFmZz/n9yTP+yYn6gz5+3IgIfth9P1j8dA7hz2V+Nd+pmA76zfCvaF9/OhDk31sXzO/z0Ce0DiOCH8y+e7j6w+kjbfp1wl876ONgGf2eXKnnyjn8iVqQfD4JQPzTw05U8EM3b8+2FBL+UqcP5953EjgEhicr8wugXO6LhS+M3/YVyb48wp+TPlDyDbJmPFk5BxpWQZIQX3juQNnj7dMb4r6pw1/dTh/bYXPsGs4hmaPrt9Z6Z7kE+A4wvtDgh83vg+W+PO4+1B+Y3yh0NdBkZbbohmu9zgWaSc/F/ofDTgx8yi00P2v8Kv3TtxpNv+3wYIr322fDLr86HPc6DXs/RC+XzHkj8FHz4+K+Dr/tiGCK99tngW7HhU5V0bEf4xxH6xscUfNTeTy8hPxG9IlveDAwQVdQDrGGqPqXOweNroNOrVSrxSLqRX3JxfiMVpzUgWq/Fcf86tz4ne9HrgZ6Z6VAqzvsus0OoyOqoB5a1MfkLzeiCxd86/H22dENr+yB+b2i4S9qNWKHogTozj5eQocNQkekWvc/YfjWGrHwKVvw1mObmh+H2Q3KbztGMNVjhqKYDnvWb70+OAxHV61WVDUqh8CPiovvj6uVvS2Fn/mhtID993Ocj8ObXHkVdqcbHnQz7Cg6ostcyEf2e11yzxuFD3vvgKP5IST7VvqIkYzMNGW0g+5+4yIKnZsdVtDCwY8cHpAXuUfiu7l9tkK8t6pyOi9Et/iN4iVzLSoUhdFzauJk6MjWzsDQN96IiQ8Gv5W9f2Dv5XbSBdogS2Z2Y30efmclG7/V3lRhNxvsAtDRI6j8fXfnAoe+GPj+uPrN8t4qv7NWNHL/ux+zGGJvxaC9kpF5wl+aWauj3cl+vntqNeuj8W0/ffv26TZNHrwm700AkvCz2vlMAHvoyI7k6MirVH0WDuZdx3cLSlTlB288SPDD3svrnLMa6V/F5odzCGMIxMeHJLI6I7iHBo3vI8m7xHcjDHBwu7dy9UGxvZfX6yN0UgCO4hs0nqxk4ocH9OKi0/16aF7jO3EZX4QD36DcsaXQ3Mtx3wxcQFK/1OKnHMZWDBnQKyZHN9NDs42P4CtE4UOp9xneNMjXe+0A+DlBPmdvxZABvWo8hw1ZONv4KsVCIQ4/hI+kXnLOGceXv9RxAGwnaebUmFsxuXufd8XgeUf7hOTohYM135dp4wvnd3xl46ta06GPODowrKDPE52UgSYrGZPIoXtAzzK7GOhcCwdrvrWNaeOLxEcqF97BjzgwqgD3E01yMbdi3MeHuKqT+AvXga7bATTtxuJ3fLVL8WHT5/ziHB0/wfycaFnYWzGuAT2WOwB4H+LjumH4brYc67MiB19+cFH3cQPQTBY1PzICfJ/mNPC66+S8WPwGKHVQfPRgja9c+dVxBh4lWxcTXPxkLKM7zKeBG3XNz3VD+GF8R1583N+7oaEeYDvh5bC3YmKeQhFEb8Z1Q/gNjmDZbGVejA+PVvLOIMQA95PNYqZoxfRZTgMPpVcIahk8W9m7deFjW7jYBqgnzDuXjAAvE54G7qJXLBRi8zt+sbt7teXC12BZuHgo2ugeLtkwcLpWTJxTKKbpVQLoFfxD39Xu7otjxYWvNU68cHGzwf7SeSnpKUEpWjFJckgkPV9+qOFCE6+Fb5x44RLUVZ/xQ7ik/4qxFZM/60a++pD6Ri2Snh+/Hyj0HVF8+Lj5MXp2w/rO/sgUopbOlyYJzZpOVjIY4JeYJxnFoTfLD/suDX3kpu2khR99rSZ/Z39sDy7BHFxLGjhbaVox4WW0fbhwNZzeDL72EfLdY8WFrzO05lmHgnII2gRXOt9PGALxJlfmHBL66kODnmvtX7EE8xscv9iEZYsd+tB33PfpJGbcd/YzPIlrQ4CVhAA1cMj6QDgsFBm6SR03kt4UP2R8MO8OXJmj2+s7g6zuTa7cQ2ByC0THh6RuxRi+US/acWfxDbaQ8dHEQXy3sbbqmQM+FJNDamD/vFQ6HyWz67Tt/JlDpWnUA5WqUigk5IeMb/MFTRxFjO9wzTs0Eff4EIYcMlqCACfJImvadr4nFBke03uckB9Kuy7jIx990JqeOYl7Ch/DfdyrJXQSYzLDRpOVjGW09xQKBx6KejHhOfgGx083Vzaf0shn+e5Of3aGP10PLRTg5Bydxpisl4A3uaZtxegOPOi3j2PTo/xufjyFeeNqixhfwcq7J+O83xaIFD20eADbiZIT+2QlasUo7gdyOOgloWcBbN/u7e7uHbUVt/F1e8OgDSSxjg9hioEEYGmSYGlStvOr9Dj6Cgp66+uF5PRQ4HtCXZca33TeTd1Di5lECMDSKL4NMk1WkmnADgCO266vJ7M8gq+NahY76xao8c0mDveXfxOUQ1AZQ4/0HcV+yJOwFWMPoTaAkzDWy+uFFPSI6xYKVtrdCDY+ph5askKaCm8qNGIFzrjtfIvd+9PGG8drl1ngobkXLz3HdXtfIof2TwTlEHwr55zJrcZCGKudP7O9CLFDhldeXy6waJYeiaWdy3z0zsP4PTSGZsLAdaz5K/Q7aREnrIa3YshOSrK9qOtit1wuY3jLLPzat1ceegWlil33cK0fZ9+msFYMaWe5D4Zvk/OlQxmidn7g1Pgq2krpbPSA7F7eYHYQHlKhkBRg88fR3q4fvUZvGHPIXVQrhj4SKXlknTINtKApKXtAz/U2jLPVYWu8c3rikMPommWiZVsJATaPnz5BFctWU3HSBgl8rXzsTcO5+4geWjofHpWmZJ9zjkdXarquG4ZPK+as/xFSW9vpHZwcOuP2yOhGDromUnl93bK/JPSWcdjbhfVe04Jn07tPQC+qh5a+kJk2QQJxMqp4JtA0W+gEqY1Gw7Ufi9rc6CUkR9GVnf9C/ArJzK95fARNb/Pq6Mc0vYv71lkuWRkqqp1PDapS8ld7MHg5CpsjxVsUKiPIbdB0cLnR2fySmB8yvScryHHbBQsejXvd08T0vONM/Pmh+4pJKVTN5mAwmLx8+XJEBf97MvFCCxIs+hKljzaOethxcemMC2hCD3Raq7kclx4a50TsKWVCVU4sbH6FKPNbpn57vUlMz/5xWu+h08AZd5bFO8k1lRP7hsF04LzuGwJwueCGt3l9hEyP0quSQKzVdNRDy6fvoQkBiPZ4tYXwo/gC6NG/bx8fvZuFZ5kepGek76EJKqOdYlDd5m99YeZHoTbbW0+p5bULM6YHTFqMpuihXYpqxXgIBmcSZnz+6cM2yOX28e07lDA233nhFSvU9HRvD43xMcKOqFaM24s1n4I6NT/H/JYJuiZ1Wmh4z59Aw9t98u7W5bYOPMf0nB7aGWMI7AjOIfQGDagDLzgu4Q/Dg+iaNrrjrefXm6hSuT7aavvC87kV/8o+Ent2IawVM31LAipNh9/SHYLHipDyQ3dyFB00u0/E7javn3vYueHVdM4jsV+E5xCXG4ORjXBz5cnzuxQZxCGH0B0jdLvYZz9Ns6u64Bn8x5nG4nOIK1DD1SKOXL67hte7+e7TUmKI6/ZTNkhu6e75Owvd9fM/H1N2OBgqjuEFWV54D43LOJMAhJMmiYF3qDqDFcbzuxgUITaswuPHyPOX7j49vybkNj3oCsvYMlGZR+GZ9cgCl30kVmgrxg+hhqcsBk0c/EpLn1ClASk+eff8093Skh0T1ymwx4/Xyd+UEDWIDXLD4Ai5T3c/XOia68Tu3IYXK7Kzj8SKbcX4hhsTuBlCMHeQIrJFAuXJk+t3z916dw2RWdCsH0HgltpNO9YtN8tlGu8cdvXYV8Q6zpTLoTLaZ5xJcDqhs92jgd1vKZ0jp4Tx7Mnm5u6uxQrhgtrcRFgh1U9/vls6L5WaTuGM/y22OvcG66Q7DFFoSZxD0APByx7a1CmyFRPBEFniS4fiOvVV51iv83Pi1U1XZkVREHfyLXLe1ixLOVtLOM7kwMNbw8SX0f6+bE3/kGdD0+2/xy6te9IJ4Tb17hfyehjWakwDG4ngtXobb+xnM0WhrZgIQ9RrpqcBXUXd1JsBVNPW8vLNzQ1CRl82pM70ra13nDCHoritGAte1w2Pfi94NC8Zer1mav4t/bCGv/ciyJv/2EJRrFYMeqhqwwOz36s9mrMMQ9dA96Cz0eh2u2+mSb2Bf9k4Oej1Tp2XiXkuokjvOBhCEcwhX6Lh7Zx0w77XfDR/WXf0q6v9fv/jEKrVaqH/GX7s91GQh+5zchF0EdRWGUKRCS7OmOGp7LlLQOu6l5t56SSdXbvsHYKoi2DOIZ0weJ0geJ70b8wfoE8oOiOBexwTHtsNqX8rJgm8B+LBs3f0nnorGh66/WBbuKndyeHwqpXZ1FZ7APymusKJ4c10mRkXDsF77YJXjYIXo1mRWQ7xK1aj3ScFvKlWDBo6fJ8IXu2BwHNCUUi9JQAeKaM7+Z8I3hmEd7GY8JyucEjJIMh9SCvmbLiWBJ72wOBZoWj8fg6xB5bRawsPzxqicZSh+9Tcn1udvcVYCHj08Tv8BU3rFSyZWYBBPrPmWbhFg2f1t1Af1LR6bNm5j4F713V74RYSnruYwXvcMr8Ic07fK6CY8X11p/CLmNf3ComEc7gIw/d7jUcLp9qcLED/FeBNFTOZuk/tV4DnApj5RdR/BXg4FmlzugjzF4AnJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSU1R/0/ottdPAAqvIIAAAAASUVORK5CYII="

    local function b64decode(data)
      local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
      local map = {}
      for i = 1, #alphabet do map[string.byte(alphabet, i)] = i - 1 end
      local out, n = {}, 0
      for i = 1, #data, 4 do
        local a, b, c, d = string.byte(data, i, i + 3)
        local v1, v2, v3, v4 = map[a] or 0, map[b] or 0, map[c], map[d]
        local num = v1 * 262144 + v2 * 4096 + (v3 or 0) * 64 + (v4 or 0)
        n = n + 1
        if v4 then
          out[n] = string.char(math.floor(num / 65536) % 256, math.floor(num / 256) % 256, num % 256)
        elseif v3 then
          out[n] = string.char(math.floor(num / 65536) % 256, math.floor(num / 256) % 256)
        else
          out[n] = string.char(math.floor(num / 65536) % 256)
        end
      end
      return table.concat(out)
    end

    local function GetLogoAsset()
      local ok, asset = pcall(function()
        local getasset = getcustomasset or getsynasset
        if not (getasset and writefile) then return nil end
        if makefolder and not (isfolder and isfolder("HavenHub")) then pcall(makefolder, "HavenHub") end
        local path = "HavenHub/haven_logo_v1.png"
        if not (isfile and isfile(path)) then writefile(path, b64decode(LOGO_B64)) end
        return getasset(path)
      end)
      return (ok and type(asset) == "string" and asset ~= "") and asset or nil
    end

    local function New(className, props, parent)
      local inst = Instance.new(className)
      for k, v in pairs(props) do inst[k] = v end
      inst.Parent = parent
      return inst
    end

    local RED = Color3.fromRGB(226, 27, 43)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local interFont = "rbxassetid://12187365364"

    local guiParent
    pcall(function() guiParent = (gethui and gethui()) or Services.CoreGui end)
    if not guiParent or RunService:IsStudio() then guiParent = LocalPlayer:WaitForChild("PlayerGui") end
    pcall(function() if guiParent:FindFirstChild("HavenHubLoader") then guiParent.HavenHubLoader:Destroy() end end)

    local gui = New("ScreenGui", {Name = "HavenHubLoader", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1000000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, guiParent)
    local root = New("Frame", {Name = "Root", BackgroundColor3 = Color3.fromRGB(17, 16, 19), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Active = true}, gui)
    local holder = New("Frame", {Name = "Holder", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(360, 440)}, root)
    local holderScale = New("UIScale", {Scale = 0.9}, holder)

    -- الشعار والدوائر
    local emblem = New("Frame", {Name = "Emblem", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.fromOffset(280, 280)}, holder)
    local function Disc(size, color, transparency, z)
      local d = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = color, BackgroundTransparency = transparency, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(size, size), ZIndex = z}, emblem)
      New("UICorner", {CornerRadius = UDim.new(1, 0)}, d)
      return d
    end
    Disc(280, RED, 0.96, 1)
    Disc(244, Color3.fromRGB(52, 13, 18), 0, 2)
    Disc(196, Color3.fromRGB(72, 16, 23), 0, 3)
    Disc(150, Color3.fromRGB(104, 22, 30), 0, 4)

    local function Ring(size, color, thickness, transparency, z)
      local r = Disc(size, WHITE, 1, z)
      local stroke = New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = color, Thickness = thickness, Transparency = transparency}, r)
      return r, stroke
    end
    Ring(244, WHITE, 1, 0.82, 5)
    local _, outerStroke = Ring(244, WHITE, 2.5, 0, 6)
    local outerGrad = New("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.55, 1), NumberSequenceKeypoint.new(1, 1)})}, outerStroke)
    local _, innerStroke = Ring(212, RED, 3, 0, 6)
    local innerGrad = New("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(1, 1)})}, innerStroke)
    local orbitDot = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = WHITE, BorderSizePixel = 0, Position = UDim2.new(0.5, -122, 0.5, 0), Size = UDim2.fromOffset(12, 12), ZIndex = 7}, emblem)
    New("UICorner", {CornerRadius = UDim.new(1, 0)}, orbitDot)

    local logoAsset = GetLogoAsset()
    local logo
    if logoAsset then
      logo = New("ImageLabel", {Name = "Logo", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(184, 184), Image = logoAsset, ScaleType = Enum.ScaleType.Fit, ZIndex = 8}, emblem)
    else
      logo = New("TextLabel", {Name = "Logo", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(184, 184), FontFace = Font.new(interFont, Enum.FontWeight.Heavy, Enum.FontStyle.Italic), Text = "H", TextColor3 = WHITE, TextSize = 120, ZIndex = 8}, emblem)
      New("UIStroke", {Color = RED, Thickness = 4}, logo)
    end
    local logoScale = New("UIScale", {Scale = 1}, logo)

    -- النصوص وشريط التقدم
    New("TextLabel", {Name = "Title", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 312), Size = UDim2.new(1, 0, 0, 30), FontFace = Font.new(interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal), Text = "H A V E N   H U B", TextColor3 = WHITE, TextSize = 26}, holder)
    local status = New("TextLabel", {Name = "Status", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 348), Size = UDim2.new(1, 0, 0, 14), FontFace = Font.new(interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), Text = "L O A D I N G", TextColor3 = RED, TextSize = 11}, holder)
    local bar = New("Frame", {Name = "Bar", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(62, 61, 66), BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0, 388), Size = UDim2.fromOffset(240, 2)}, holder)
    local fill = New("Frame", {Name = "Fill", BackgroundColor3 = WHITE, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1)}, bar)
    local barDot = New("Frame", {Name = "Dot", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = WHITE, BorderSizePixel = 0, Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(7, 7), ZIndex = 2}, bar)
    New("UICorner", {CornerRadius = UDim.new(1, 0)}, barDot)
    local percent = New("TextLabel", {Name = "Percent", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 400), Size = UDim2.new(1, 0, 0, 14), FontFace = Font.new(interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = "0%", TextColor3 = WHITE, TextSize = 12, TextTransparency = 0.1}, holder)

    -- تصغير تلقائي للشاشات الصغيرة (الجوال)
    local fitScale = 1
    pcall(function()
      local vp = workspace.CurrentCamera.ViewportSize
      fitScale = math.clamp(math.min(vp.X / 420, vp.Y / 500), 0.55, 1)
    end)
    TweenService:Create(holderScale, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = fitScale}):Play()

    local startClock = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
      local t = os.clock() - startClock
      local angle = (t * 150) % 360
      outerGrad.Rotation = angle
      innerGrad.Rotation = -(t * 95) % 360
      local rad = math.rad(angle)
      orbitDot.Position = UDim2.new(0.5, -math.cos(rad) * 122, 0.5, -math.sin(rad) * 122)
      logoScale.Scale = 1 + math.sin(t * 2.2) * 0.025
      L.Progress = L.Progress + (L.Target - L.Progress) * math.clamp(dt * 6, 0, 1)
      if L.Target - L.Progress < 0.2 then L.Progress = L.Target end
      local p = L.Progress / 100
      fill.Size = UDim2.fromScale(p, 1)
      barDot.Position = UDim2.fromScale(p, 0.5)
      percent.Text = tostring(math.floor(L.Progress + 0.5)) .. "%"
    end)

    function L:Set(value, text)
      if L.Done then return end
      L.Target = math.clamp(value, L.Target, 100)
      if text then status.Text = text end
    end

    local function Close()
      if L.Done then return end
      L.Done = true
      pcall(function()
        local group = New("CanvasGroup", {BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1)}, gui)
        root.Parent = group
        TweenService:Create(holderScale, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = fitScale * 1.08}):Play()
        local fade = TweenService:Create(group, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {GroupTransparency = 1})
        fade:Play()
        fade.Completed:Wait()
      end)
      if conn then conn:Disconnect() end
      gui:Destroy()
      if L.OnClose then pcall(L.OnClose) end
    end

    function L:Finish()
      if L.Done then return end
      L.Target = 100
      status.Text = "R E A D Y"
      local minShown = 2.2 - (os.clock() - startClock)
      if minShown > 0 then task.wait(minShown) end
      repeat task.wait() until L.Progress >= 100 or L.Done
      task.wait(0.35)
      Close()
    end

    -- حماية: لو تعطل السكربت لا تبقى الشاشة عالقة
    task.delay(60, Close)

    return L
  end)()
  Loader:Set(12)
  local HavenLib = (function()
    local haven = {Options = {}, Folder = "HavenHub"}
    getgenv().Options = getgenv().Options or {}

    local isStudio = RunService:IsStudio()
    local windowState = true
    local acrylicBlur = true
    local hasGlobalSetting = false
    local tabs = {}
    local currentTabInstance = nil
    local tabIndex = 0

    local Theme = {
      BaseBg          = Color3.fromRGB(9, 9, 14),
      SidebarBg       = Color3.fromRGB(6, 6, 10),
      SectionBg       = Color3.fromRGB(13, 13, 20),
      CardBg          = Color3.fromRGB(19, 19, 29),
      CardHover       = Color3.fromRGB(26, 26, 40),
      PromptBg        = Color3.fromRGB(12, 12, 18),
      Accent          = Color3.fromRGB(124, 58, 237),
      AccentSecondary = Color3.fromRGB(56, 189, 248),
      ToggleOff       = Color3.fromRGB(30, 30, 44),
      ToggleHeadOff   = Color3.fromRGB(130, 130, 155),
      StrokeIdle      = Color3.fromRGB(45, 45, 65),
      StrokeHover     = Color3.fromRGB(124, 58, 237)
    }

    local assets = {
      interFont       = "rbxassetid://12187365364",
      userInfoBlurred = "rbxassetid://18824089198",
      buttonImage     = "rbxassetid://10709791437",
      shadowImage     = "rbxassetid://1316045217"
    }

    local function Tween(inst, info, props)
      return TweenService:Create(inst, info, props)
    end

    local function Create(className, props, children)
      local inst = Instance.new(className)
      for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
      end
      for _, child in ipairs(children or {}) do
        child.Parent = inst
      end
      if props and props.Parent then inst.Parent = props.Parent end
      return inst
    end

    local function AttachCardHover(cardFrame, strokeObj)
      cardFrame.MouseEnter:Connect(function()
        Tween(cardFrame, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {BackgroundColor3 = Theme.CardHover}):Play()
        if strokeObj then Tween(strokeObj, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {Color = Theme.StrokeHover, Transparency = 0.45}):Play() end
      end)
      cardFrame.MouseLeave:Connect(function()
        Tween(cardFrame, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {BackgroundColor3 = Theme.CardBg}):Play()
        if strokeObj then Tween(strokeObj, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {Color = Theme.StrokeIdle, Transparency = 0.65}):Play() end
      end)
    end

    pcall(function()
      if makefolder then
        makefolder("HavenHub")
        makefolder("HavenHub/settings")
      end
    end)

    function haven:Window(Settings)
      local WindowFunctions = {}
      if Settings.AcrylicBlur ~= nil then acrylicBlur = Settings.AcrylicBlur end

      local screenGui = Create("ScreenGui", {Name = "HavenHubUI", ResetOnSpawn = false, DisplayOrder = 100, IgnoreGuiInset = true, ScreenInsets = Enum.ScreenInsets.None, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = (isStudio and LocalPlayer.PlayerGui) or Services.CoreGui})
      local notifications = Create("Frame", {Name = "Notifications", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 20, Parent = screenGui}, {
        Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom}),
        Create("UIPadding", {PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 14)})
      })

      local base = Create("Frame", {Name = "Base", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.BaseBg, BackgroundTransparency = acrylicBlur and 0.03 or 0, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = Settings.Size or UDim2.fromOffset(620, 480), Parent = screenGui}, {
        Create("UIScale", {Name = "BaseUIScale"}),
        Create("UICorner", {CornerRadius = UDim.new(0, 14)}),
        Create("ImageLabel", {Name = "DropShadow", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 44, 1, 44), ZIndex = 0, Image = assets.shadowImage, ImageColor3 = Theme.Accent, ImageTransparency = 0.72, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(10, 10, 118, 118)})
      })

      local baseStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Thickness = 1.5, Transparency = 0.3, Parent = base})
      Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(0.5, Theme.AccentSecondary), ColorSequenceKeypoint.new(1, Theme.Accent)}), Rotation = 35, Parent = baseStroke})

      local sidebar = Create("Frame", {Name = "Sidebar", BackgroundColor3 = Theme.SidebarBg, BackgroundTransparency = 0.3, BorderSizePixel = 0, Size = UDim2.fromScale(0.29, 1), Parent = base}, {
        Create("UICorner", {CornerRadius = UDim.new(0, 14)}),
        Create("Frame", {Name = "Divider", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.82, BorderSizePixel = 0, Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0)})
      })

      local windowControls = Create("Frame", {Name = "WindowControls", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Parent = sidebar}, {
        Create("Frame", {Name = "Divider", AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.88, BorderSizePixel = 0, Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1)})
      })

      local controls = Create("Frame", {Name = "Controls", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = windowControls}, {
        Create("UIListLayout", {Padding = UDim.new(0, 7), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 14)})
      })

      local exit = Create("TextButton", {Name = "Exit", Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(244, 63, 94), BorderSizePixel = 0, Size = UDim2.fromOffset(10, 10), Parent = controls}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
      local minimize = Create("TextButton", {Name = "Minimize", Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(245, 158, 11), BorderSizePixel = 0, LayoutOrder = 1, Size = UDim2.fromOffset(10, 10), Parent = controls}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
      Create("TextButton", {Name = "Maximize", Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(16, 185, 129), BackgroundTransparency = 0.6, Active = false, Interactable = false, LayoutOrder = 2, Size = UDim2.fromOffset(10, 10), Parent = controls}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

      local information = Create("Frame", {Name = "Information", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, 62), Parent = sidebar}, {
        Create("Frame", {Name = "Divider", AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.88, BorderSizePixel = 0, Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1)})
      })
      local informationHolder = Create("Frame", {Name = "InformationHolder", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = information}, {
        Create("UIPadding", {PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 10)})
      })
      local globalSettingsButton = Create("ImageButton", {Name = "GlobalSettingsButton", Image = "rbxassetid://18767849817", ImageColor3 = Theme.AccentSecondary, ImageTransparency = 0.25, AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(16, 16), Parent = informationHolder})

      LocalPlayer:SetAttribute("Elite", true)

      task.spawn(function()
        repeat task.wait() until shared.tabs ~= nil
        for key, tabObj in pairs(shared.tabs) do
          if key ~= "Settings" then shared[key] = tabObj:Section({Side = "Left"}) end
        end
        shared.loaded = true
        shared.done = true
      end)

      local titleFrame = Create("Frame", {Name = "TitleFrame", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = informationHolder}, {
        Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})
      })
      Create("TextLabel", {Name = "Title", FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal), Text = '<font color="#A855F7">HAVEN</font> <font color="#FFFFFF">HUB</font>', TextColor3 = Color3.fromRGB(255, 255, 255), RichText = true, TextSize = 19, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, -24, 0, 0), Parent = titleFrame})
      Create("TextLabel", {Name = "Subtitle", FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), RichText = true, Text = "MURDER MYSTERY 2  |  PRO", TextColor3 = Theme.AccentSecondary, TextSize = 10, TextTransparency = 0.2, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1, -24, 0, 0), Parent = titleFrame})

      local sidebarGroup = Create("Frame", {Name = "SidebarGroup", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 96), Size = UDim2.new(1, 0, 1, -96), Parent = sidebar}, {
        Create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10)})
      })
      local userInfo = Create("Frame", {Name = "UserInfo", AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 64), Parent = sidebarGroup}, {
        Create("Frame", {Name = "Divider", AnchorPoint = Vector2.new(0, 0), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.88, BorderSizePixel = 0, Position = UDim2.fromScale(0, 0), Size = UDim2.new(1, 0, 0, 1)})
      })
      local informationGroup = Create("Frame", {Name = "InformationGroup", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = userInfo}, {
        Create("UIPadding", {PaddingLeft = UDim.new(0, 8)}),
        Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})
      })

      local headshotImage, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
      local headshot = Create("ImageLabel", {Name = "Headshot", BackgroundTransparency = 1, Size = UDim2.fromOffset(34, 34), Image = (isReady and headshotImage) or "rbxassetid://0", Parent = informationGroup}, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.25})
      })
      local userAndDisplayFrame = Create("Frame", {Name = "UserAndDisplayFrame", BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1, -44, 0, 32), Parent = informationGroup}, {
        Create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 2)}),
        Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})
      })
      local displayName = Create("TextLabel", {Name = "DisplayName", FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal), Text = LocalPlayer.DisplayName, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, TextTransparency = 0.1, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Parent = userAndDisplayFrame})
      local username = Create("TextLabel", {Name = "Username", FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = "@" .. LocalPlayer.Name, TextColor3 = Theme.AccentSecondary, TextSize = 11, TextTransparency = 0.35, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, LayoutOrder = 1, Parent = userAndDisplayFrame})

      local tabSwitchers = Create("Frame", {Name = "TabSwitchers", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -72), Parent = sidebarGroup})
      local tabSwitchersScrollingFrame = Create("ScrollingFrame", {Name = "TabSwitchersScrollingFrame", AutomaticCanvasSize = Enum.AutomaticSize.Y, BottomImage = "", CanvasSize = UDim2.new(), ScrollBarImageTransparency = 0.8, ScrollBarThickness = 1, TopImage = "", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = tabSwitchers}, {
        Create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}),
        Create("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2)})
      })

      local content = Create("Frame", {Name = "Content", AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(1, 0), Size = UDim2.fromScale(0.71, 1), Parent = base})
      local topbar = Create("Frame", {Name = "Topbar", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56), Parent = content}, {
        Create("Frame", {Name = "Divider", AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.88, BorderSizePixel = 0, Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1)})
      })
      local elements = Create("Frame", {Name = "Elements", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = topbar}, {
        Create("UIPadding", {PaddingLeft = UDim.new(0, 22), PaddingRight = UDim.new(0, 20)})
      })
      local moveIcon = Create("ImageButton", {Name = "MoveIcon", Image = "rbxassetid://10734900011", ImageColor3 = Theme.AccentSecondary, ImageTransparency = 0.35, AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(16, 16), Parent = elements})
      local dragInteract = Create("TextButton", {Name = "Interact", Text = "", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Size = UDim2.fromOffset(500, 50), Position = UDim2.new(0.5, -230, 0.5, 0), Parent = moveIcon})

      local dragging_, dragInput, dragStart, startPos = false, nil, nil, nil
      dragInteract.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
          dragging_ = true dragStart = input.Position startPos = base.Position
          input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging_ = false end end)
        end
      end)
      dragInteract.InputChanged:Connect(function(input)
        if dragging_ and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then dragInput = input end
      end)
      UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging_ then
          local delta = input.Position - dragStart
          base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
      end)

      local currentTab = Create("TextLabel", {Name = "CurrentTab", FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal), RichText = true, Text = "", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15, TextTransparency = 0.1, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromScale(0.9, 0), Parent = elements})
      local globalSettings = Create("Frame", {Name = "GlobalSettings", AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = Theme.PromptBg, BorderSizePixel = 0, Position = UDim2.fromScale(0.298, 0.104), ZIndex = 15, Parent = base}, {
        Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.5}),
        Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
        Create("UIPadding", {PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 10)}),
        Create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
      })
      local globalSettingsUIScale = Create("UIScale", {Scale = 0, Parent = globalSettings})
      local gsToggled = false
      globalSettingsButton.MouseButton1Click:Connect(function()
        if hasGlobalSetting then
          gsToggled = not gsToggled
          Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = gsToggled and 1 or 0}):Play()
        end
      end)

      function WindowFunctions:GlobalSetting(gSettings)
        hasGlobalSetting = true
        local gsBtn = Create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromOffset(200, 30), Parent = globalSettings}, {
          Create("UIPadding", {PaddingLeft = UDim.new(0, 15)}),
          Create("UIListLayout", {Padding = UDim.new(0, 10), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})
        })
        local check = Create("Frame", {BackgroundColor3 = Theme.AccentSecondary, BackgroundTransparency = gSettings.Default and 0 or 1, Size = UDim2.fromOffset(8, 8), LayoutOrder = -1, Parent = gsBtn}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
        local sName = Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = gSettings.Name, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextTransparency = gSettings.Default and 0.1 or 0.5, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Parent = gsBtn})
        local st = gSettings.Default
        gsBtn.MouseButton1Click:Connect(function()
          st = not st check.BackgroundTransparency = st and 0 or 1 sName.TextTransparency = st and 0.1 or 0.5
          if gSettings.Callback then task.spawn(gSettings.Callback, st) end
        end)
        return {}
      end

      function WindowFunctions:TabGroup()
        local GroupFuncs = {}
        local sectionTabSwitchers = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0), Parent = tabSwitchersScrollingFrame}, {
          Create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
        })

        function GroupFuncs:Tab(tSettings)
          local TabFunctions = {}
          tabIndex = tabIndex + 1
          local tabSwitcher = Create("TextButton", {Name = "TabSwitcher", Text = "", AutoButtonColor = false, BackgroundColor3 = Theme.CardBg, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = tabIndex, Parent = sectionTabSwitchers}, {
            Create("UICorner", {CornerRadius = UDim.new(0, 8)})
          })
          local tabStroke = Create("UIStroke", {Name = "TabSwitcherUIStroke", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 1, Parent = tabSwitcher})
          local activeBar = Create("Frame", {Name = "ActiveBar", AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.AccentSecondary, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 18), Parent = tabSwitcher}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
          local innerHolder = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = tabSwitcher}, {
            Create("UIListLayout", {Padding = UDim.new(0, 10), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}),
            Create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
          })
          local tabImage = tSettings.Image and Create("ImageLabel", {Name = "TabImage", Image = tSettings.Image, ImageColor3 = Theme.AccentSecondary, ImageTransparency = 0.4, BackgroundTransparency = 1, Size = UDim2.fromOffset(16, 16), Parent = innerHolder})
          local tabSwitcherName = Create("TextLabel", {Name = "TabSwitcherName", FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), Text = tSettings.Name, RichText = true, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextTransparency = 0.4, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0), LayoutOrder = 1, Parent = innerHolder})

          local elements1 = Create("Frame", {Name = "Elements", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 1, -56)}, {Create("UIPadding", {PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 8)})})
          local elementsScrolling = Create("ScrollingFrame", {Name = "ElementsScrolling", AutomaticCanvasSize = Enum.AutomaticSize.Y, BottomImage = "", CanvasSize = UDim2.new(), ScrollBarImageColor3 = Theme.Accent, ScrollBarImageTransparency = 0.3, ScrollBarThickness = 2, TopImage = "", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = elements1}, {
            Create("UIPadding", {PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4)}),
            Create("UIListLayout", {Padding = UDim.new(0, 14), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder})
          })
          local left = Create("Frame", {Name = "Left", AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(0.5, -10, 0, 0), Parent = elementsScrolling}, {Create("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})})

          function TabFunctions:Section()
            local SectionFunctions = {}
            local section = Create("Frame", {Name = "Section", AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.SectionBg, BackgroundTransparency = 0.25, BorderSizePixel = 0, Size = UDim2.fromScale(2, -3.1), Parent = left}, {
              Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
              Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Transparency = 0.55}),
              Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}),
              Create("UIPadding", {PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 14)})
            })

            function SectionFunctions:Button(bSettings)
              local button = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.CardBg, BackgroundTransparency = 0.15, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), Parent = section}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)})
              })
              local bStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Transparency = 0.65, Parent = button})
              AttachCardHover(button, bStroke)
              local buttonInteract = Create("TextButton", {FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), RichText = true, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextTransparency = 0.15, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = bSettings.Name, Parent = button})
              Create("ImageLabel", {Image = assets.buttonImage, ImageColor3 = Theme.AccentSecondary, ImageTransparency = 0.2, AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(14, 14), Parent = button})
              buttonInteract.MouseButton1Click:Connect(function() if bSettings.Callback then bSettings.Callback() end end)
              return {UpdateName = function(_, n) buttonInteract.Text = n end, SetVisibility = function(_, s) button.Visible = s end}
            end

            function SectionFunctions:Toggle(Flag, DisplayName, Config, Callback)
              if type(Config) == "function" then Callback = Config Config = {} end
              Config = Config or {}
              local ToggleFunctions = {IgnoreConfig = false, Class = "Toggle", Callback = Callback}
              local toggle = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.CardBg, BackgroundTransparency = 0.15, Size = UDim2.new(1, 0, 0, 38), Parent = section}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)})
              })
              local tStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Transparency = 0.65, Parent = toggle})
              AttachCardHover(toggle, tStroke)

              local toggleName = Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = DisplayName, RichText = true, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextTransparency = 0.3, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, -56, 0, 0), Parent = toggle})
              local switchBg = Create("TextButton", {Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Theme.ToggleOff, Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(40, 20), Parent = toggle}, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.88})
              })
              local knob = Create("Frame", {AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.ToggleHeadOff, Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(14, 14), Parent = switchBg}, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)})
              })

              local tInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
              local function ToggleState(State)
                Tween(switchBg, tInfo, {BackgroundColor3 = State and Theme.Accent or Theme.ToggleOff}):Play()
                Tween(knob, tInfo, {BackgroundColor3 = State and Color3.fromRGB(255, 255, 255) or Theme.ToggleHeadOff, Position = State and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}):Play()
                Tween(toggleName, tInfo, {TextTransparency = State and 0.05 or 0.3}):Play()
                ToggleFunctions.State = State
              end
              local togglebool = (Config.State == true)
              ToggleState(togglebool)
              local function DoToggle()
                togglebool = not togglebool ToggleState(togglebool)
                if ToggleFunctions.Callback then task.spawn(ToggleFunctions.Callback, togglebool) end
              end
              switchBg.MouseButton1Click:Connect(DoToggle)
              function ToggleFunctions:Toggle() DoToggle() end
              function ToggleFunctions:UpdateState(State)
                togglebool = State ToggleState(togglebool) Options[Flag] = self
                if togglebool and ToggleFunctions.Callback then task.spawn(ToggleFunctions.Callback, togglebool) end
              end
              function ToggleFunctions:GetState() return togglebool end
              function ToggleFunctions:GetValue() return togglebool end
              function ToggleFunctions:UpdateName(Name) toggleName.Text = Name end
              function ToggleFunctions:SetVisibility(State) toggle.Visible = State end
              if Flag then Options[Flag] = ToggleFunctions haven.Options[Flag] = ToggleFunctions end
              return ToggleFunctions
            end

            function SectionFunctions:Slider(Flag, Name, Minimum, Maximum, Default, _, Callback)
              local SliderFunctions = {IgnoreConfig = false, Class = "Slider", Callback = Callback}
              local slider = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.CardBg, BackgroundTransparency = 0.15, Size = UDim2.new(1, 0, 0, 42), Parent = section}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)})
              })
              local sStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Transparency = 0.65, Parent = slider})
              AttachCardHover(slider, sStroke)

              local sliderName = Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = Name, RichText = true, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextTransparency = 0.25, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 0.5), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.5), Parent = slider})
              local sliderElements = Create("Frame", {AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(1, 0), Size = UDim2.fromScale(0.65, 1), Parent = slider}, {
                Create("UIListLayout", {Padding = UDim.new(0, 12), FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})
              })
              local sliderValue = Create("TextBox", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal), Text = tostring(Default), TextColor3 = Theme.AccentSecondary, TextSize = 11, BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.86, LayoutOrder = 1, Size = UDim2.fromOffset(42, 22), Parent = sliderElements}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.65})
              })
              local sliderBar = Create("Frame", {BackgroundColor3 = Theme.ToggleOff, BorderSizePixel = 0, Size = UDim2.fromOffset(120, 6), Parent = sliderElements}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
              local sliderFill = Create("Frame", {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.fromScale(0.5, 1), Parent = sliderBar}, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentSecondary)})})
              })
              local sliderHead = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(12, 12), ZIndex = 2, Parent = sliderBar}, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Create("UIStroke", {Color = Theme.Accent, Thickness = 2})
              })
              local touchArea = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 3, Parent = sliderBar})

              local dragging, finalValue = false, Default
              local function SetValue(val, ignorecallback)
                local posXScale = (typeof(val) == "Instance") and math.clamp((val.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1) or math.clamp((val - Minimum) / (Maximum - Minimum), 0, 1)
                sliderHead.Position = UDim2.new(posXScale, 0, 0.5, 0)
                sliderFill.Size = UDim2.fromScale(posXScale, 1)
                finalValue = posXScale * (Maximum - Minimum) + Minimum
                sliderValue.Text = tostring(math.round(finalValue))
                if not ignorecallback and SliderFunctions.Callback then task.spawn(SliderFunctions.Callback, finalValue) end
                SliderFunctions.Value = finalValue
              end
              SetValue(Default, true)
              touchArea.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true SetValue(inp) end end)
              touchArea.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
              sliderValue.FocusLost:Connect(function()
                local num = tonumber(sliderValue.Text:match("%-?%d+%.?%d*"))
                if num then SetValue(math.clamp(num, Minimum, Maximum)) else sliderValue.Text = tostring(math.round(finalValue)) end
              end)
              UserInputService.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then SetValue(inp) end end)

              function SliderFunctions:UpdateName(n) sliderName.Text = n end
              function SliderFunctions:SetVisibility(s) slider.Visible = s end
              function SliderFunctions:UpdateValue(v) SetValue(tonumber(v) or Default, true) end
              function SliderFunctions:GetValue() return finalValue end
              if Flag then Options[Flag] = SliderFunctions haven.Options[Flag] = SliderFunctions end
              return SliderFunctions
            end

            function SectionFunctions:Input(iSettings, Flag)
              local InputFunctions = {IgnoreConfig = false, Class = "Input", Callback = iSettings.Callback}
              local input = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.CardBg, BackgroundTransparency = 0.15, Size = UDim2.new(1, 0, 0, 38), Parent = section}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)})
              })
              local iStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Transparency = 0.65, Parent = input})
              AttachCardHover(input, iStroke)

              local inputName = Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = iSettings.Name, RichText = true, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextTransparency = 0.25, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 0.5), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.5), Parent = input})
              local inputBox = Create("TextBox", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = iSettings.Default or "", PlaceholderText = iSettings.Placeholder or "", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, TextTransparency = 0.15, AnchorPoint = Vector2.new(1, 0.5), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Theme.BaseBg, BackgroundTransparency = 0.2, ClipsDescendants = true, Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(50, 24), Parent = input}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.6}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}),
                Create("UISizeConstraint", {MaxSize = Vector2.new(175, 999)})
              })
              inputBox.FocusLost:Connect(function()
                if iSettings.AcceptedCharacters == "Numeric" then inputBox.Text = inputBox.Text:gsub("[^%d-]", "") end
                InputFunctions.Text = inputBox.Text
                if InputFunctions.Callback then task.spawn(InputFunctions.Callback, inputBox.Text) end
              end)
              function InputFunctions:UpdateName(n) inputName.Text = n end
              function InputFunctions:SetVisibility(s) input.Visible = s end
              function InputFunctions:GetInput() return inputBox.Text end
              function InputFunctions:UpdateText(t) inputBox.Text = t or "" InputFunctions.Text = inputBox.Text if InputFunctions.Callback then task.spawn(InputFunctions.Callback, inputBox.Text) end end
              if Flag then haven.Options[Flag] = InputFunctions Options[Flag] = InputFunctions end
              return InputFunctions
            end

            function SectionFunctions:Keybind(Flag, Name, Config, Callback)
              if type(Config) == "function" then Callback = Config end
              local KeybindFunctions = {IgnoreConfig = false, Class = "Keybind", Callback = Callback}
              local keybind = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.CardBg, BackgroundTransparency = 0.15, Size = UDim2.new(1, 0, 0, 38), Parent = section}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)})
              })
              local kStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Transparency = 0.65, Parent = keybind})
              AttachCardHover(keybind, kStroke)

              local keybindName = Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = Name, RichText = true, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextTransparency = 0.25, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 0.5), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.5), Parent = keybind})
              local binderBox = Create("TextBox", {CursorPosition = -1, FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal), PlaceholderText = "...", Text = "NONE", TextColor3 = Theme.AccentSecondary, TextSize = 11, AnchorPoint = Vector2.new(1, 0.5), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Theme.BaseBg, BackgroundTransparency = 0.2, Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(36, 22), Parent = keybind}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.6}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
              })
              local focused, skipNextKey, binded = false, nil, nil
              function KeybindFunctions:Bind(Key) if Key then binded = Key binderBox.Text = Key.Name else binded = nil binderBox.Text = "NONE" end end
              function KeybindFunctions:GetBind() return binded end
              function KeybindFunctions:SetBind(Key) KeybindFunctions:Bind(Key) end
              binderBox.Focused:Connect(function() focused = true binderBox.Text = "..." end)
              binderBox.FocusLost:Connect(function() focused = false binderBox.Text = binded and binded.Name or "NONE" end)
              UserInputService.InputBegan:Connect(function(inp)
                if focused and inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode ~= Enum.KeyCode.Unknown then
                  binded = inp.KeyCode binderBox.Text = inp.KeyCode.Name skipNextKey = inp.KeyCode focused = false binderBox:ReleaseFocus()
                end
              end)
              UserInputService.InputEnded:Connect(function(inp)
                if skipNextKey and inp.KeyCode == skipNextKey then skipNextKey = nil return end
                if not focused and inp.UserInputType == Enum.UserInputType.Keyboard and binded and inp.KeyCode == binded then
                  if KeybindFunctions.Callback then KeybindFunctions.Callback(binded) end
                end
              end)
              if Flag then haven.Options[Flag] = KeybindFunctions Options[Flag] = KeybindFunctions end
              return KeybindFunctions
            end

            function SectionFunctions:Dropdown(dSettings, Flag)
              local DropdownFunctions = {IgnoreConfig = false, Class = "Dropdown", Callback = dSettings.Callback}
              local Selected, OptionObjs = {}, {}
              local dropdown = Create("Frame", {BackgroundColor3 = Theme.CardBg, BackgroundTransparency = 0.15, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 38), ClipsDescendants = true, Parent = section}, {
                Create("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)}),
                Create("UICorner", {CornerRadius = UDim.new(0, 8)})
              })
              local dStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Transparency = 0.65, Parent = dropdown})
              AttachCardHover(dropdown, dStroke)

              local interact = Create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Parent = dropdown})
              local dropdownName = Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = dSettings.Name, RichText = true, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextTransparency = 0.25, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 38), Parent = dropdown})
              Create("ImageLabel", {Image = "rbxassetid://18865373378", ImageColor3 = Theme.AccentSecondary, ImageTransparency = 0.2, AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.new(1, 0, 0, 12), Size = UDim2.fromOffset(14, 14), Parent = dropdown})
              local dropdownFrame = Create("Frame", {BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.fromScale(1, 1), Visible = false, AutomaticSize = Enum.AutomaticSize.Y, Parent = dropdown}, {
                Create("UIPadding", {PaddingTop = UDim.new(0, 40), PaddingBottom = UDim.new(0, 10)}),
                Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
              })

              local function CalculateDropdownSize()
                local totalHeight, count = 0, 0
                for _, v in pairs(dropdownFrame:GetChildren()) do
                  if not v:IsA("UIComponent") and v.Visible then totalHeight = totalHeight + v.AbsoluteSize.Y count = count + 1 end
                end
                return totalHeight + (4 * math.max(0, count - 1)) + 50
              end
              local function ToggleOption(optionName)
                if not OptionObjs[optionName] then return end
                for name, opt in pairs(OptionObjs) do
                  opt.Dot.BackgroundTransparency = (name == optionName) and 0 or 1
                  opt.NameLabel.TextTransparency = (name == optionName) and 0.05 or 0.5
                end
                Selected = {optionName}
                DropdownFunctions.Value = optionName
                dropdownName.Text = dSettings.Name .. '  |  <font color="#38BDF8">' .. optionName .. '</font>'
              end
              local dropped = false
              interact.MouseButton1Click:Connect(function()
                dropped = not dropped dropdownFrame.Visible = dropped
                Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = dropped and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, 38)}):Play()
              end)
              local function addOption(i, v)
                if OptionObjs[v] then return end
                local option = Create("TextButton", {Text = "", BackgroundColor3 = Theme.BaseBg, BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 28), Parent = dropdownFrame}, {
                  Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                  Create("UIPadding", {PaddingLeft = UDim.new(0, 10)}),
                  Create("UIListLayout", {Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})
                })
                local dot = Create("Frame", {BackgroundColor3 = Theme.AccentSecondary, BackgroundTransparency = 1, Size = UDim2.fromOffset(6, 6), LayoutOrder = -1, Parent = option}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                local optionName = Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = v, RichText = true, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, TextTransparency = 0.5, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Parent = option})
                OptionObjs[v] = {Index = i, Button = option, NameLabel = optionName, Dot = dot}
                option.MouseButton1Click:Connect(function()
                  ToggleOption(v)
                  if DropdownFunctions.Callback then task.spawn(DropdownFunctions.Callback, Selected[1]) end
                end)
                if dropped then dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize()) end
              end
              for i, v in pairs(dSettings.Options or {}) do addOption(i, v) end
              if dSettings.Default then
                local def = (type(dSettings.Default) == "number") and (dSettings.Options and dSettings.Options[dSettings.Default]) or dSettings.Default
                if type(def) == "string" and OptionObjs[def] then ToggleOption(def) end
              end
              function DropdownFunctions:GetValue() return Selected[1] end
              function DropdownFunctions:UpdateSelection(s) if type(s) == "string" and OptionObjs[s] then ToggleOption(s) end end
              function DropdownFunctions:InsertOptions(newOpts) for i, v in pairs(newOpts or {}) do addOption(i, v) end end
              function DropdownFunctions:RemoveOptions(rem)
                for _, n in ipairs(rem or {}) do if OptionObjs[n] then OptionObjs[n].Button:Destroy() OptionObjs[n] = nil end end
              end
              if Flag then Options[Flag] = DropdownFunctions haven.Options[Flag] = DropdownFunctions end
              return DropdownFunctions
            end

            function SectionFunctions:SubLabel(sSettings)
              local subLabel = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = section}, {
                Create("UIListLayout", {Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}),
                Create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 2)})
              })
              Create("Frame", {BackgroundColor3 = Theme.AccentSecondary, BorderSizePixel = 0, Size = UDim2.fromOffset(3, 13), LayoutOrder = -1, Parent = subLabel}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
              local subLabelText = Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal), RichText = true, Text = string.upper(sSettings.Text or sSettings.Name or ""), TextColor3 = Theme.AccentSecondary, TextSize = 11, TextTransparency = 0.1, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 0), Parent = subLabel})
              return {UpdateName = function(_, New) subLabelText.Text = string.upper(New) end, SetVisibility = function(_, State) subLabel.Visible = State end}
            end

            function SectionFunctions:Divider()
              local div = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 1), Parent = section}, {
                Create("UIPadding", {PaddingBottom = UDim.new(0, 4), PaddingTop = UDim.new(0, 4)}),
                Create("Frame", {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.85, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1)})
              })
              return {Remove = function() div:Destroy() end, SetVisibility = function(_, s) div.Visible = s end}
            end

            return SectionFunctions
          end

          local function SelectCurrentTab()
            local easetime = 0.18
            if currentTabInstance then currentTabInstance.Parent = nil end
            for _, v in pairs(tabSwitchersScrollingFrame:GetDescendants()) do
              if v.Name == "TabSwitcher" then
                Tween(v, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
                Tween(v:FindFirstChild("TabSwitcherUIStroke"), TweenInfo.new(easetime, Enum.EasingStyle.Sine), {Transparency = 1}):Play()
                if v:FindFirstChild("ActiveBar") then Tween(v.ActiveBar, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play() end
                if v:FindFirstChild("TabSwitcherName", true) then Tween(v:FindFirstChild("TabSwitcherName", true), TweenInfo.new(easetime, Enum.EasingStyle.Sine), {TextTransparency = 0.45}):Play() end
                if v:FindFirstChild("TabImage", true) then Tween(v:FindFirstChild("TabImage", true), TweenInfo.new(easetime, Enum.EasingStyle.Sine), {ImageTransparency = 0.45}):Play() end
              end
            end
            tabs[tabSwitcher].Parent = content
            currentTabInstance = tabs[tabSwitcher]
            currentTab.Text = '<font color="#A855F7">HAVEN HUB</font>  /  ' .. string.upper(tSettings.Name)
            Tween(tabSwitcher, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.25}):Play()
            Tween(tabStroke, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {Transparency = 0.45}):Play()
            Tween(activeBar, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {BackgroundTransparency = 0}):Play()
            Tween(tabSwitcherName, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {TextTransparency = 0}):Play()
            if tabImage then Tween(tabImage, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {ImageTransparency = 0}):Play() end
          end

          tabSwitcher.MouseButton1Click:Connect(SelectCurrentTab)
          function TabFunctions:Select() SelectCurrentTab() end
          function TabFunctions:InsertConfigSection(_, THISWINDOW)
            THISWINDOW:GlobalSetting({Name = "UI Transparency", Default = THISWINDOW:GetAcrylicBlurState(), Callback = function(b) THISWINDOW:SetAcrylicBlurState(b) end})
            THISWINDOW:GlobalSetting({Name = "Show User Info", Default = THISWINDOW:GetUserInfoState(), Callback = function(b) THISWINDOW:SetUserInfoState(b) end})
            local configSection = TabFunctions:Section({Side = "Left"})
            configSection:SubLabel({Text = "CONFIGURATION & SERVER CONTROLS"})
            configSection:Toggle("SaveSettings", "Auto Save Settings", function()
              local lastSave = 0
              repeat task.wait(1)
                if os.clock() - lastSave >= 5 then lastSave = os.clock() haven:SaveConfig(game.PlaceId) end
              until not Options.SaveSettings:GetValue()
            end)
            configSection:Toggle("AutoRejoin", "Auto Rejoin On Disconnect", function(value)
              if value then
                repeat task.wait(1)
                  pcall(function()
                    Services.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                      if child.Name == "ErrorPrompt" then Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end
                    end)
                  end)
                until not Options.AutoRejoin:GetValue()
              end
            end)
            configSection:Divider()
            configSection:Button({Name = "Rejoin Current Server", Callback = function() Services.TeleportService:Teleport(game.PlaceId, LocalPlayer) end})
            configSection:Button({Name = "Server Hop (New Server)", Callback = function()
              pcall(function()
                local Site = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                for _, v in pairs(Site.data) do
                  if tonumber(v.maxPlayers) > tonumber(v.playing) and tostring(v.id) ~= tostring(game.JobId) then
                    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(v.id), LocalPlayer)
                    task.wait(4)
                  end
                end
              end)
            end})
          end
          tabs[tabSwitcher] = elements1
          return TabFunctions
        end
        return GroupFuncs
      end

      function WindowFunctions:Notify(nSettings)
        local notification = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.PromptBg, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(nSettings.SizeX or 270, 0), Parent = notifications}, {
          Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.35}),
          Create("UICorner", {CornerRadius = UDim.new(0, 10)})
        })
        local nScale = Create("UIScale", {Scale = 0, Parent = notification})
        local nInfo = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = notification}, {
          Create("UIPadding", {PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 10)})
        })
        Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal), RichText = true, Text = string.upper(nSettings.Title or "HAVEN HUB"), TextColor3 = Theme.AccentSecondary, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 0), Parent = nInfo})
        Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = nSettings.Description or "", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, TextTransparency = 0.2, TextWrapped = true, RichText = true, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 0), Parent = nInfo}, {Create("UIPadding", {PaddingTop = UDim.new(0, 18)})})
        task.spawn(function()
          Tween(nScale, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 1}):Play()
          task.wait(nSettings.Lifetime or nSettings.Duration or 4)
          local out = Tween(nScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 0})
          out:Play() out.Completed:Wait() notification:Destroy()
        end)
      end

      function WindowFunctions:Dialog(dSettings)
        local dialog = Create("Frame", {BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.45, Size = UDim2.fromScale(1, 1), ZIndex = 25, Parent = base}, {Create("UICorner", {CornerRadius = UDim.new(0, 14)})})
        local prompt = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.PromptBg, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(310, 0), Parent = dialog}, {
          Create("UIStroke", {Color = Theme.Accent, Transparency = 0.35}),
          Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
          Create("UIPadding", {PaddingBottom = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingTop = UDim.new(0, 20)}),
          Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})
        })
        Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal), RichText = true, Text = dSettings.Title or "HAVEN HUB", TextColor3 = Theme.AccentSecondary, TextSize = 16, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0), Parent = prompt})
        Create("TextLabel", {FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal), RichText = true, Text = dSettings.Description or "", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, TextTransparency = 0.25, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(1, 0), Parent = prompt})
        local interactions = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.fromScale(1, 0), Parent = prompt}, {Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})})
        for _, v in pairs(dSettings.Buttons or {}) do
          local btn = Create("TextButton", {FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), Text = v.Name, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.75, Size = UDim2.fromScale(1, 0), Parent = interactions}, {
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Create("UIPadding", {PaddingBottom = UDim.new(0, 8), PaddingTop = UDim.new(0, 8)})
          })
          btn.MouseButton1Click:Connect(function() if v.Callback then v.Callback() end dialog:Destroy() end)
        end
      end

      function WindowFunctions:SetState(State) windowState = State base.Visible = State end
      function WindowFunctions:GetState() return windowState end
      function WindowFunctions:SetAcrylicBlurState(State) acrylicBlur = State base.BackgroundTransparency = State and 0.03 or 0 end
      function WindowFunctions:GetAcrylicBlurState() return acrylicBlur end
      local showUserInfo = true
      function WindowFunctions:SetUserInfoState(State)
        showUserInfo = State
        headshot.Image = State and ((isReady and headshotImage) or "rbxassetid://0") or assets.userInfoBlurred
        username.Text = State and ("@" .. LocalPlayer.Name) or "@hidden"
        displayName.Text = State and LocalPlayer.DisplayName or "Haven Hub User"
      end
      function WindowFunctions:GetUserInfoState() return showUserInfo end

      local MenuKeybind = Settings.Keybind or Enum.KeyCode.LeftControl
      UserInputService.InputEnded:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == MenuKeybind then WindowFunctions:SetState(not WindowFunctions:GetState()) end
      end)
      exit.MouseButton1Click:Connect(function()
        screenGui:Destroy() pcall(function() LocalPlayer.PlayerGui.HavenClickButton:Destroy() end)
        shared.loaded = nil shared.VertexLoaded = nil
      end)
      minimize.MouseButton1Click:Connect(function() WindowFunctions:SetState(false) end)

      function haven:SaveConfig(Path)
        if not Path or not writefile then return false end
        local data = {objects = {}}
        for flag, opt in pairs(haven.Options) do
          if opt.Class == "Toggle" then table.insert(data.objects, {type = "Toggle", flag = flag, state = opt.State or false})
          elseif opt.Class == "Slider" then table.insert(data.objects, {type = "Slider", flag = flag, value = tostring(opt.Value or 0)})
          elseif opt.Class == "Input" then table.insert(data.objects, {type = "Input", flag = flag, text = opt.Text or ""})
          elseif opt.Class == "Dropdown" then table.insert(data.objects, {type = "Dropdown", flag = flag, value = opt.Value}) end
        end
        local ok, enc = pcall(HttpService.JSONEncode, HttpService, data)
        if ok then pcall(writefile, haven.Folder .. "/settings/" .. tostring(Path) .. ".json", enc) end
        return true
      end

      function haven:LoadConfig(Path)
        shared.tabs = nil
        if not Path or not isfile or not readfile then return false end
        local file = haven.Folder .. "/settings/" .. tostring(Path) .. ".json"
        if not isfile(file) then return false end
        local ok, dec = pcall(HttpService.JSONDecode, HttpService, readfile(file))
        if not ok or not dec or not dec.objects then return false end
        for _, opt in ipairs(dec.objects) do
          local target = haven.Options[opt.flag]
          if target then
            task.spawn(function()
              if opt.type == "Toggle" and opt.state ~= nil then target:UpdateState(opt.state)
              elseif opt.type == "Slider" and opt.value then target:UpdateValue(opt.value)
              elseif opt.type == "Input" and opt.text then target:UpdateText(opt.text)
              elseif opt.type == "Dropdown" and opt.value then target:UpdateSelection(opt.value) end
            end)
          end
        end
        return true
      end

      pcall(function()
        local pGui = LocalPlayer:WaitForChild("PlayerGui")
        if pGui:FindFirstChild("HavenClickButton") then pGui.HavenClickButton:Destroy() end
        local cGui = Create("ScreenGui", {Name = "HavenClickButton", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999999, ZIndexBehavior = Enum.ZIndexBehavior.Global, Parent = pGui})
        local cBtn = Create("TextButton", {Name = "ClickButton", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -20, 0.5, 0), Size = UDim2.fromOffset(48, 48), BackgroundTransparency = 0.08, BackgroundColor3 = Theme.BaseBg, FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold, Enum.FontStyle.Normal), Text = "HH", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 16, AutoButtonColor = false, ZIndex = 999999, Parent = cGui}, {Create("UICorner", {CornerRadius = UDim.new(0, 12)})})
        local cStroke = Create("UIStroke", {Thickness = 2, Transparency = 0.1, Color = Color3.fromRGB(255, 255, 255), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = cBtn})
        Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentSecondary)}), Parent = cStroke})
        local bDrag, bMoved, bStart, bPos = false, false, nil, nil
        cBtn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then bStart = inp.Position bPos = cBtn.Position bDrag = false bMoved = false end end)
        UserInputService.InputChanged:Connect(function(inp)
          if bStart and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - bStart
            if not bMoved and delta.Magnitude >= 8 then bMoved = true bDrag = true end
            if bDrag then cBtn.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + delta.X, bPos.Y.Scale, bPos.Y.Offset + delta.Y) end
          end
        end)
        UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then bStart = nil bDrag = false end end)
        cBtn.Activated:Connect(function() if not bMoved then WindowFunctions:SetState(not WindowFunctions:GetState()) end end)
      end)

      return WindowFunctions
    end
    return haven
  end)()

  -- ============================================================================
  -- 2. تشغيل نافذة HAVEN HUB وتبويبات اللعبة (بدون إيموجيات)
  -- ============================================================================
  shared.VertexLoaded = true
  shared.Premium = true
  Loader:Set(30)

  repeat task.wait() until LocalPlayer.PlayerGui:FindFirstChild("MainGUI")

  local platform = UserInputService:GetPlatform()
  local isDesktop = (platform == Enum.Platform.Windows or platform == Enum.Platform.OSX) or (UserInputService.KeyboardEnabled and UserInputService.MouseEnabled and not UserInputService.TouchEnabled)
  local Window = HavenLib:Window({
    Size = isDesktop and UDim2.fromOffset(620, 480) or UDim2.fromOffset(540, 400),
    DragStyle = 1,
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.LeftControl,
    AcrylicBlur = true
  })
  Window:SetState(false)
  Loader.OnClose = function() Window:SetState(true) end
  Loader:Set(50)

  Vertex = Window:TabGroup()
  shared.tabs = {
    Main     = Vertex:Tab({Name = "Main & Farm", Image = "rbxassetid://10734934585"}),
    Roles    = Vertex:Tab({Name = "Combat & Roles", Image = "rbxassetid://10747373426"}),
    Target   = Vertex:Tab({Name = "Target Control", Image = "rbxassetid://10709818534"}),
    Visual   = Vertex:Tab({Name = "Visuals & ESP", Image = "rbxassetid://10709818399"}),
    Player   = Vertex:Tab({Name = "LocalPlayer", Image = "rbxassetid://10747373176"}),
    Tracker  = Vertex:Tab({Name = "Webhooks", Image = "rbxassetid://10709811110"}),
    Settings = Vertex:Tab({Name = "Settings", Image = "rbxassetid://10734950309"})
  }

  repeat task.wait() until shared.loaded
  Loader:Set(65)

  -- ============================================================================
  -- 3. الدوال والمميزات الكاملة (Murder Mystery 2)
  -- ============================================================================
  local v17, v14, v15, v18, val, v91
  local tbl, roles = {}, {}
  local Noclipping, antifling, unboxConnection

  local res = {
    emote = function(_, emoteName) pcall(function() ReplicatedStorage.Remotes.Misc.PlayEmote:Fire(emoteName) end) end,
    fling = function(_, targetPlayer)
      pcall(function()
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local tRoot = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and tRoot then
          local savedCF, start = myRoot.CFrame, os.clock()
          while os.clock() - start < 1.2 and tRoot.Parent do
            RunService.Heartbeat:Wait()
            myRoot.CFrame = tRoot.CFrame
            myRoot.AssemblyLinearVelocity = Vector3.new(9000, 9000, 9000)
            myRoot.AssemblyAngularVelocity = Vector3.new(9000, 9000, 9000)
          end
          myRoot.AssemblyLinearVelocity = Vector3.zero
          myRoot.AssemblyAngularVelocity = Vector3.zero
          myRoot.CFrame = savedCF
        end
      end)
    end
  }

  local function EquipTool(toolName)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
    if hum and tool then hum:EquipTool(tool) end
  end

  local function GetMapElement(arg1)
    for _, child in pairs(workspace:GetChildren()) do
      if child:IsA("Model") and not string.find(string.lower(child.Name), "lobby") then
        if arg1 == "CoinContainer" and child:FindFirstChild("CoinContainer") then return child.CoinContainer
        elseif arg1 == "Spawns" and child:FindFirstChild("Spawns") then return child.Spawns end
      end
    end
    return nil
  end

  local function GetGunDrop()
    local spawns = GetMapElement("Spawns")
    return (spawns and spawns.Parent and spawns.Parent:FindFirstChild("GunDrop")) or false
  end

  local function IsPlayerAlive(arg1, arg2)
    if not arg2 or not arg1 then return false end
    local pData = arg2[arg1.Name] or arg2
    if pData and (pData.Killed or pData.Dead) then
      return (arg1.Character and arg1.Character:FindFirstChild("HumanoidCloned")) ~= nil
    end
    return true
  end

  local function FindPlayerWithTool(toolName)
    for _, p in ipairs(Players:GetPlayers()) do
      if p.Backpack:FindFirstChild(toolName) or (p.Character and p.Character:FindFirstChild(toolName)) then return p.Name end
    end
    return nil
  end

  local function SetStats(ws, jp)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
      if ws then hum.WalkSpeed = ws end
      if jp then hum.JumpPower = jp end
    end
  end

  CoinAttribute = function(coinPart, checkOnly)
    if not coinPart then return false end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or not hum.Parent.PrimaryPart then return false end
    local dist = (coinPart.Position - hum.Parent.PrimaryPart.Position).Magnitude
    if dist <= 4 and shared.Premium then
      task.wait()
      if firetouchinterest then
        firetouchinterest(coinPart, root, 1) task.wait(0.1) firetouchinterest(coinPart, root, 0)
      end
      coinPart:Destroy()
    elseif dist <= 2 then
      task.wait(0.1) coinPart.Name = "haven_collected"
    end
    if coinPart:GetAttribute("Collected") == true then return false end
    return checkOnly == true
  end

  local function IsBagFull()
    if not roles then return false end
    local elite = LocalPlayer:GetAttribute("Elite")
    local coins = tonumber(roles.Coins) or 0
    return (elite ~= nil and coins >= 50) or (elite == nil and coins >= 40)
  end

  local function TweenTo(targetCF, speed, useQuad, waitCollect, targetCoin)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if v17 then v17:Cancel() end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local dur = math.clamp((root.Position - targetCF.Position).Magnitude / speed, 0.15, 5)
    local tween = TweenService:Create(root, TweenInfo.new(dur, useQuad and Enum.EasingStyle.Quad or Enum.EasingStyle.Linear, useQuad and Enum.EasingDirection.Out or Enum.EasingDirection.In), {CFrame = targetCF})
    v17 = tween tween:Play()
    if waitCollect and targetCoin then
      repeat task.wait()
        if not CoinAttribute(targetCoin, true) or IsBagFull() then break end
      until not IsPlayerAlive(LocalPlayer, roles)
    end
    v17 = nil
  end

  ShootMurderer = function()
    if not v14 then return end
    local gun = (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun")) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun"))
    local mPlayer = Players:FindFirstChild(v14)
    local mChar = mPlayer and mPlayer.Character
    local mRoot = mChar and mChar:FindFirstChild("HumanoidRootPart")
    local mHum = mChar and mChar:FindFirstChild("Humanoid")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not gun or not mRoot or not mHum or not myRoot then return end

    local predictedCF = CFrame.new(mRoot.Position + (mRoot.AssemblyLinearVelocity or Vector3.zero) * Vector3.new(0, 0.5, 0) * 0.18666666666666665 + (mHum.MoveDirection or Vector3.zero) * 2.8)
    local originCF
    if not Options.KillM:GetValue() then
      local att = myRoot:FindFirstChild("GunShoulderAttachment")
      originCF = att and att.WorldCFrame or myRoot.CFrame
    else
      local att = mRoot:FindFirstChild("RootAttachment")
      originCF = att and (att.WorldCFrame * CFrame.new(0, 2, 0)) or mRoot.CFrame
    end
    local handle = gun:FindFirstChild("Handle")
    local reload = handle and handle:FindFirstChild("Reload")
    if reload and not reload.Playing then
      local shoot = workspace:FindFirstChild(LocalPlayer.Name) and workspace[LocalPlayer.Name]:FindFirstChild("Gun") and workspace[LocalPlayer.Name].Gun:FindFirstChild("Shoot")
      if shoot then shoot:FireServer(originCF, predictedCF) end
    end
  end

  local function IsVisible(targetPlayer)
    local myRoot = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChild("HumanoidRootPart")
    local tRoot = targetPlayer and targetPlayer ~= LocalPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local hit = workspace:Raycast(myRoot.Position, (tRoot.Position - myRoot.Position).Unit * 50, params)
    return not hit or hit.Instance.Parent == targetPlayer.Character
  end

  local function EnableFloat()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and not root:FindFirstChild("BodyVelocity") then
      local bv = Instance.new("BodyVelocity", root)
      bv.Name = "BodyVelocity" bv.Velocity = Vector3.zero bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    end
  end

  local function DisableFloat()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
  end

  local function ResetOrLobby()
    pcall(function()
      if Options.Mode:GetValue() == "Nearest" then LocalPlayer.Character.Humanoid.Health = 0 return end
      for _, child in pairs(workspace:GetChildren()) do
        if (child:IsA("Model") or child:IsA("Folder")) and string.find(string.lower(child.Name), "lobby") then
          for _, desc in pairs(child:GetDescendants()) do
            if desc:IsA("SpawnLocation") then TweenTo(CFrame.new(desc.Position + Vector3.new(0, 5, 0)), 5000) return end
          end
        end
      end
    end)
  end

  local function FindCoin(rootPart, mode)
    local container = GetMapElement("CoinContainer")
    if not container then return nil end
    local closest, huge, nearTbl, safeTbl = nil, math.huge, {}, {}
    local mPlayer = v14 and Players:FindFirstChild(v14)
    local mRoot = mPlayer and mPlayer.Character and mPlayer.Character:FindFirstChild("HumanoidRootPart")
    local mPos = mRoot and mRoot.Position or nil

    for _, child in pairs(container:GetChildren()) do
      if CoinAttribute(child, true) and child.Name == "Coin_Server" and child:FindFirstChild("TouchInterest") and child:FindFirstChild("CoinVisual") and IsPlayerAlive(LocalPlayer, roles) then
        local pos = child.CoinVisual.Position
        local mag = (rootPart.Position - pos).Magnitude
        if mPos and (pos - mPos).Magnitude >= 25 then table.insert(safeTbl, child) end
        if mag <= 50 then table.insert(nearTbl, child) end
        if mag < huge then huge = mag closest = child end
      end
    end
    if mode == "closest" then return closest
    elseif mode == "random" then
      if #nearTbl > 0 then return nearTbl[math.random(1, #nearTbl)]
      elseif #safeTbl > 0 then return safeTbl[math.random(1, #safeTbl)] end
    end
    return nil
  end

  local function MoveToCoin(coin, rootPart)
    local pos = coin.CoinVisual.Position
    local mag = (rootPart.Position - pos).Magnitude
    local speed = shared.Premium and (shared.speed or 23) or 21
    if not IsBagFull() and CoinAttribute(coin, true) then
      local cf = CFrame.new(pos.X, pos.Y, pos.Z)
      if mag > 200 then
        rootPart.CFrame = cf * CFrame.new(0, 10, 0) task.wait(2)
        TweenTo(cf * CFrame.new(0, 1.5, 0), 5000, false)
      elseif Options.Mode:GetValue() == "Randomize" then
        TweenTo(cf * CFrame.new(0, 1.5, 0), 20, true, true, coin)
      else
        TweenTo(cf * CFrame.new(0, 1.5, 0), speed, false)
      end
    end
  end

  local function RunAutoFarm()
    pcall(function()
      local char = LocalPlayer.Character
      local hum = char and char:FindFirstChild("Humanoid")
      local root = char and char:FindFirstChild("HumanoidRootPart")
      if not v14 then DisableFloat() return end

      local function farmStep()
        if not Options.AutoFarm:GetValue() or not IsPlayerAlive(LocalPlayer, roles) or not root then return end
        local mode = (Options.Mode:GetValue() == "Nearest" or Options.Mode:GetValue() == "Nearest + XP Farm") and "closest" or "random"
        local coin = FindCoin(root, mode)
        if coin and v18 ~= coin then EnableFloat() MoveToCoin(coin, root) v18 = coin end
      end

      if not IsBagFull() or not root or not hum or hum.Health <= 0 or not IsPlayerAlive(LocalPlayer, roles) then farmStep() return end
      if Options.KillAll:GetValue() or Options.KillM:GetValue() or Options.AutoShoot:GetValue() then
        if v14 == LocalPlayer.Name or v15 == LocalPlayer.Name then farmStep() else ResetOrLobby() end
      else ResetOrLobby() end
    end)
  end

  local function UpdateChams()
    for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
        local char = player.Character
        if not char then
          if tbl[player] then tbl[player]:Destroy() tbl[player] = nil end
        else
          local hl = char:FindFirstChild("Highlight") or Instance.new("Highlight", char)
          tbl[player] = hl
          if not IsPlayerAlive(player, roles) then hl.FillColor = Color3.fromRGB(255, 255, 255)
          else
            local item = roles and roles[player.Name]
            if item and item.Role == "Murderer" then hl.FillColor = Color3.fromRGB(225, 0, 0)
            elseif item and (item.Role == "Sheriff" or item.Role == "Hero") then hl.FillColor = Color3.fromRGB(0, 110, 255)
            else hl.FillColor = Color3.fromRGB(76, 215, 134) end
          end
        end
      end
    end
  end

  local function CreateNameESP(player)
    if player ~= LocalPlayer and player.Character then
      local head = player.Character:FindFirstChild("Head")
      if head and not head:FindFirstChild("UsernameTag") then
        local bb = Instance.new("BillboardGui", head)
        bb.Name = "UsernameTag" bb.Adornee = head bb.Size = UDim2.new(0, 200, 0, 50) bb.StudsOffset = Vector3.new(0, 2.5, 0) bb.AlwaysOnTop = true
        local lbl = Instance.new("TextLabel", bb)
        lbl.Text = player.Name lbl.TextSize = 18 lbl.BackgroundTransparency = 1 lbl.TextColor3 = Color3.fromRGB(255, 255, 255) lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) lbl.TextStrokeTransparency = 0.4 lbl.Size = UDim2.new(1, 0, 1, 0) lbl.Font = Enum.Font.GothamBold
      end
    end
  end

  local function ClearESP()
    for k, v in pairs(tbl) do if v then v:Destroy() end tbl[k] = nil end
    for _, p in pairs(Players:GetPlayers()) do
      local head = p.Character and p.Character:FindFirstChild("Head")
      if head and head:FindFirstChild("UsernameTag") then head.UsernameTag:Destroy() end
    end
  end

  -- ============================================================================
  -- 4. بناء الأزرار والخيارات (بدون إيموجيات نهائياً)
  -- ============================================================================
  shared.Main:SubLabel({Text = "AUTO FARMING & COLLECTION"})
  shared.Main:Toggle("AutoFarm", "Enable Coin Auto-Farm", function(arg1)
    if arg1 then
      Noclipping = RunService.Stepped:Connect(function()
        if LocalPlayer.Character and IsPlayerAlive(LocalPlayer, roles) then
          for _, d in pairs(LocalPlayer.Character:GetDescendants()) do if d:IsA("BasePart") and d.CanCollide then d.CanCollide = false end end
        end
      end)
    end
    repeat task.wait() RunAutoFarm() until not Options.AutoFarm:GetValue()
    if Noclipping then Noclipping:Disconnect() end
    DisableFloat()
  end)

  shared.Main:Dropdown({Name = "Farm Mode", Multi = false, Required = true, Options = {"Nearest + XP Farm", "Nearest", "Randomize"}, Default = 2, Callback = function() DisableFloat() end}, "Mode")
  shared.Main:Divider()
  shared.Main:SubLabel({Text = "SURVIVAL & ROUND UTILITIES"})

  shared.Main:Toggle("AutoGrab", "Automatically Grab Gun", function(arg1)
    if arg1 then
      repeat task.wait()
        pcall(function()
          if v14 and IsPlayerAlive(LocalPlayer, roles) and v14 ~= LocalPlayer.Name then
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local gunDrop = GetGunDrop()
            if myRoot and gunDrop and (IsBagFull() or not Options.AutoFarm:GetValue()) then gunDrop.CFrame = myRoot.CFrame end
          end
        end)
      until not Options.AutoGrab:GetValue()
    end
  end)

  shared.Main:Toggle("DodgeKnife", "Dodge Thrown Knife", function(arg1)
    if arg1 then
      repeat task.wait()
        pcall(function()
          for _, child in ipairs(workspace:GetChildren()) do
            if child.Name == "ThrowingKnife" then
              local blade = child:FindFirstChild("BladePosition")
              local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
              if blade and root and (blade.Position - root.Position).Magnitude <= 15 then
                local pos = root.Position
                root.CFrame = CFrame.new(pos.X, pos.Y + 100, pos.Z) task.wait(0.2) root.CFrame = CFrame.new(pos)
              end
            end
          end
        end)
      until not Options.DodgeKnife:GetValue()
    end
  end)

  shared.Main:Toggle("EndRound", "Auto End Round", function(arg1)
    if arg1 then
      Window:Notify({Title = "HAVEN HUB", Description = "Flings Murderer when you are not in the round.", Duration = 5})
      repeat task.wait()
        local mPlayer = v14 and Players:FindFirstChild(v14)
        if mPlayer and not IsPlayerAlive(LocalPlayer, roles) and v14 ~= LocalPlayer.Name then res:fling(mPlayer) task.wait(3) end
      until not Options.EndRound:GetValue()
    end
  end)

  shared.Main:Divider()
  shared.Main:SubLabel({Text = "QUICK TELEPORTS"})
  shared.Main:Button({Name = "Teleport To Lobby", Callback = function()
    for _, child in pairs(workspace:GetChildren()) do
      if (child:IsA("Model") or child:IsA("Folder")) and string.find(string.lower(child.Name), "lobby") then
        for _, desc in pairs(child:GetDescendants()) do
          if desc:IsA("SpawnLocation") then TweenTo(CFrame.new(desc.Position + Vector3.new(0, 5, 0)), 5000) return end
        end
      end
    end
  end})

  shared.Main:Button({Name = "Teleport To Map", Callback = function()
    local spawns = GetMapElement("Spawns")
    if spawns then
      for _, desc in ipairs(spawns:GetDescendants()) do
        if desc:IsA("BasePart") then TweenTo(desc.CFrame * CFrame.new(0, 5, 0), 5000) return end
      end
    else Window:Notify({Title = "HAVEN HUB", Description = "Map does not exist yet.", Duration = 5}) end
  end})

  -- قسم Target
  shared.Target:SubLabel({Text = "TARGET PLAYER CONTROLS"})
  local TargetDropdown = shared.Target:Dropdown({Name = "Target", Search = true, Multi = false, Required = false, Options = {}, Default = {}, Callback = function() end}, "Target")
  local res12 = Players.PlayerAdded:Connect(function(p) TargetDropdown:InsertOptions({p.Name}) end)
  local res13 = Players.PlayerRemoving:Connect(function(p) TargetDropdown:RemoveOptions({p.Name}) end)
  for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then TargetDropdown:InsertOptions({p.Name}) end end

  shared.Target:Toggle("TargetFling", "Fling Target", function(arg1)
    if arg1 then
      repeat task.wait()
        local target = Options.Target:GetValue() and Players:FindFirstChild(Options.Target:GetValue())
        if target then res:fling(target) end
        task.wait(3)
      until not Options.TargetFling:GetValue()
    end
  end)

  shared.Target:Toggle("Spectate", "Spectate Target", function(arg1)
    if arg1 then
      repeat task.wait()
        local target = Options.Target:GetValue() and Players:FindFirstChild(Options.Target:GetValue())
        if target and target.Character and target.Character:FindFirstChild("Head") then workspace.CurrentCamera.CameraSubject = target.Character.Head end
      until not Options.Spectate:GetValue()
      if LocalPlayer.Character then workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end
    end
  end)

  shared.Target:Toggle("Annoy", "Loop Go To Target", function(arg1)
    if arg1 then
      repeat task.wait()
        pcall(function()
          local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
          local tChar = Options.Target:GetValue() and workspace:FindFirstChild(Options.Target:GetValue())
          if myRoot and tChar and tChar:FindFirstChild("HumanoidRootPart") then myRoot.CFrame = tChar.HumanoidRootPart.CFrame end
        end)
      until not Options.Annoy:GetValue()
    end
  end)

  shared.Target:Button({Name = "Teleport To Target", Callback = function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tChar = Options.Target:GetValue() and workspace:FindFirstChild(Options.Target:GetValue())
    if myRoot and tChar and tChar:FindFirstChild("HumanoidRootPart") then myRoot.CFrame = tChar.HumanoidRootPart.CFrame end
  end})

  shared.Target:Divider()
  shared.Target:Toggle("FlingSheriff", "Fling Sheriff", function(arg1)
    if arg1 then
      repeat task.wait()
        local sPlayer = v15 and Players:FindFirstChild(v15)
        if sPlayer and v15 ~= LocalPlayer.Name then res:fling(sPlayer) task.wait(3) end
      until not Options.FlingSheriff:GetValue()
    end
  end)

  shared.Target:Toggle("FlingMurderer", "Fling Murderer", function(arg1)
    if arg1 then
      repeat task.wait()
        local mPlayer = v14 and Players:FindFirstChild(v14)
        if mPlayer and v14 ~= LocalPlayer.Name then res:fling(mPlayer) task.wait(3) end
      until not Options.FlingMurderer:GetValue()
    end
  end)

  -- قسم Visuals
  shared.Visual:SubLabel({Text = "PLAYER & GUN ESP"})
  shared.Visual:Toggle("Chams", "Player Role Chams", function(arg1)
    if arg1 then
      repeat task.wait(0.2) UpdateChams() until not Options.Chams:GetValue()
      ClearESP()
    end
  end)

  shared.Visual:Toggle("GunDropCham", "Dropped Gun Highlight", function(arg1)
    while arg1 and Options.GunDropCham:GetValue() do
      task.wait(0.5)
      local gunDrop = GetGunDrop()
      if gunDrop and not gunDrop:FindFirstChild("GunESP") then
        local hl = Instance.new("Highlight", gunDrop)
        hl.Name = "GunESP" hl.FillTransparency = 0.5 hl.FillColor = Color3.fromRGB(128, 225, 0) hl.OutlineColor = Color3.fromRGB(0, 163, 0)
      end
    end
  end)

  shared.Visual:Toggle("Render", "Disable 3D Rendering When Unfocused", function(arg1)
    if arg1 then
      UserInputService.WindowFocusReleased:Connect(function() if Options.Render:GetValue() then RunService:Set3dRenderingEnabled(false) end end)
      UserInputService.WindowFocused:Connect(function() RunService:Set3dRenderingEnabled(true) end)
    end
  end)

  shared.Visual:Toggle("Names", "Player Name ESP", function()
    while Options.Names:GetValue() do
      task.wait(0.5)
      for _, p in pairs(Players:GetPlayers()) do if p.Character then CreateNameESP(p) end end
    end
    ClearESP()
  end)

  shared.Visual:Divider()
  shared.Visual:Dropdown({Name = "Emote", Multi = false, Required = true, Options = {"ninja", "dab", "floss", "headless", "zen", "zombie", "sit"}, Default = 1, Callback = function() end}, "Emote")
  shared.Visual:Toggle("AutoEmote", "Auto Emote", function()
    while Options.AutoEmote:GetValue() do task.wait(0.2) res:emote(Options.Emote:GetValue()) end
  end)

  -- قسم Combat & Roles
  shared.Roles:SubLabel({Text = "MURDERER COMBAT"})
  shared.Roles:Toggle("KillAura", "Knife Kill Aura", function(arg1)
    if arg1 then
      repeat task.wait()
        pcall(function()
          local hasKnife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
          for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and hasKnife and IsPlayerAlive(p, roles) then
              local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
              if tRoot and (tRoot.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= Options.AuraDistance:GetValue() and v14 == LocalPlayer.Name then
                EquipTool("Knife") LocalPlayer.Character.Knife.Events.HandleTouched:FireServer(tRoot)
              end
            end
          end
        end)
      until not Options.KillAura:GetValue()
    end
  end)

  shared.Roles:Slider("AuraDistance", "Aura Distance", 5, 50, 5, "Percent", function() end)

  KillAll = function()
    pcall(function()
      EquipTool("Knife")
      for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and workspace:FindFirstChild(p.Name) and workspace[p.Name]:FindFirstChild("HumanoidRootPart") then
          LocalPlayer.Character.Knife.Events.HandleTouched:FireServer(workspace[p.Name].HumanoidRootPart)
        end
      end
    end)
  end

  shared.Roles:Toggle("KillAll", "Auto Kill All", function(arg1)
    if arg1 then
      repeat task.wait()
        if v14 and (IsBagFull() or not Options.AutoFarm:GetValue()) and v14 == LocalPlayer.Name then KillAll() end
      until not Options.KillAll:GetValue()
    end
  end)

  shared.Roles:Divider()
  shared.Roles:SubLabel({Text = "SHERIFF COMBAT"})
  shared.Roles:Toggle("SilentAim", "Gun Silent Aim", function(arg1)
    if arg1 then
      local conn = nil
      repeat task.wait()
        local char = LocalPlayer.Character
        if char then
          local gun = char:FindFirstChild("Gun")
          if not gun and conn then conn:Disconnect() conn = nil
          elseif gun and v15 == LocalPlayer.Name and not conn then
            conn = gun.Activated:Connect(function()
              local mPlayer = v14 and Players:FindFirstChild(tostring(v14))
              local mRoot = mPlayer and mPlayer.Character and mPlayer.Character:FindFirstChild("HumanoidRootPart")
              if mRoot then
                local myRoot = char:FindFirstChild("HumanoidRootPart")
                local originCF = myRoot and (myRoot:FindFirstChild("RootAttachment") and myRoot.RootAttachment.WorldCFrame or myRoot.CFrame) or char:GetPrimaryPartCFrame()
                if gun:FindFirstChild("Shoot") then gun.Shoot:FireServer(originCF, mRoot.CFrame) end
              end
            end)
          end
        end
      until not Options.SilentAim:GetValue()
      if conn then conn:Disconnect() end
    end
  end)

  shared.Roles:Toggle("KillM", "Kill Murderer (Blatant)", function(arg1)
    if arg1 then
      repeat task.wait()
        if IsBagFull() or not Options.AutoFarm:GetValue() then EquipTool("Gun") ShootMurderer() end
      until not Options.KillM:GetValue()
    end
  end)

  shared.Roles:Toggle("AutoShoot", "Auto Shoot Murderer", function(arg1)
    if arg1 then
      repeat task.wait()
        pcall(function()
          if v14 and v15 and v15 == LocalPlayer.Name then
            local mPlayer = Players:FindFirstChild(v14)
            if mPlayer and IsVisible(mPlayer) and not Options.KillM:GetValue() and (IsBagFull() or not Options.AutoFarm:GetValue()) then
              EquipTool("Gun") ShootMurderer()
            end
          end
        end)
      until not Options.AutoShoot:GetValue()
    end
  end)

  shared.Roles:Keybind("ShootBind", "Shoot Murderer Keybind", function() pcall(function() EquipTool("Gun") ShootMurderer() end) end)

  -- قسم Webhooks
  shared.Tracker:SubLabel({Text = "DISCORD WEBHOOK INTEGRATION"})
  local WebhookInput = shared.Tracker:Input({Name = "Webhook URL", Placeholder = "https://discord.com/api/webhooks/...", AcceptedCharacters = "All", Callback = function() end}, "Webhook")
  shared.Tracker:Divider()
  shared.Tracker:Toggle("CoinTracker", "Coin Tracker", function() end)
  shared.Tracker:Input({Name = "Minutes To Send Webhook", Placeholder = "minutes", AcceptedCharacters = "Numeric", Callback = function(arg1)
    local num = tonumber(arg1) if num then Options.WebhookTimeInSeconds = num * 60 end
  end}, "WebhookTime")
  local TrackerStatusLabel = shared.Tracker:SubLabel({Text = "COIN TRACKER IS TURNED OFF"})
  shared.Tracker:Divider()

  shared.Tracker:Toggle("BoxNotification", "Unbox Notification", function(arg1)
    if not arg1 then
      if unboxConnection then unboxConnection:Disconnect() unboxConnection = nil end
    else
      local shop = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop")
      local itemService = require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("ItemService"))
      local syncDB = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
      local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
      unboxConnection = shop.BoxController.Event:Connect(function(items)
        local now = os.date("!*t", os.time())
        for _, value in ipairs(items) do
          local itemId, boxId = value.RewardedItemId, value.MysteryBoxId
          local info = itemService:GetDisplayInfo(itemId, "Weapons")
          local rarity = (syncDB.Weapons[itemId] and syncDB.Weapons[itemId].Rarity) or "Unknown"
          local isChroma = info.Chroma and true or false
          pcall(function()
            req({
              Url = WebhookInput:GetInput(),
              Method = "POST",
              Headers = {["Content-Type"] = "application/json"},
              Body = HttpService:JSONEncode({
                username = "Haven Hub - Unbox Notification",
                content = isChroma and "@everyone" or "",
                embeds = {{
                  title = "Mystery Box Unboxed",
                  description = "**Name:** " .. tostring(info.Name) .. "\n**Rarity:** " .. tostring(rarity) .. "\n**Box:** " .. tostring(boxId) .. "\n**Chroma:** `" .. tostring(isChroma) .. "`",
                  timestamp = string.format("%d-%d-%dT%02d:%02d:%02dZ", now.year, now.month, now.day, now.hour, now.min, now.sec),
                  footer = {text = "Powered by Haven Hub"}
                }}
              })
            })
          end)
        end
      end)
    end
  end)

  -- قسم LocalPlayer
  shared.Player:SubLabel({Text = "CHARACTER MODIFIERS"})
  shared.Player:Toggle("WalkSpeed", "Walk Speed", function(arg1)
    if arg1 then
      repeat task.wait() SetStats(Options.WalkSpeedSlider:GetValue(), nil) until not Options.WalkSpeed:GetValue()
      SetStats(16, nil)
    end
  end)
  shared.Player:Slider("WalkSpeedSlider", "Walk Speed", 16, 100, 16, "Percent", function() end)

  shared.Player:Toggle("Jump", "Jump Power", function(arg1)
    if arg1 then
      repeat task.wait() SetStats(nil, Options.JumpPower:GetValue()) until not Options.Jump:GetValue()
      SetStats(nil, 50)
    end
  end)
  shared.Player:Slider("JumpPower", "Jump Power", 50, 100, 50, "Percent", function() end)
  shared.Player:Divider()

  local isInvis = false
  shared.Player:Keybind("Invis", "Invisible [FE]", function(arg1)
    if arg1 then
      isInvis = not isInvis
      if not isInvis then
        local chair = workspace:FindFirstChild("invischair")
        if chair then Window:Notify({Title = "HAVEN HUB", Description = "Invisibility disabled", Duration = 4}) chair:Destroy() end
      else
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local savedCF = root.CFrame
        task.wait() LocalPlayer.Character:MoveTo(Vector3.new(-25, -59536, 100)) task.wait(0.35)
        local seat = Instance.new("Seat", workspace)
        seat.Anchored = false seat.CanCollide = false seat.Name = "invischair" seat.Transparency = 1 seat.Position = Vector3.new(-25.95, 84, 3537.55)
        local weld = Instance.new("Weld", seat)
        weld.Part0 = seat weld.Part1 = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        task.wait() seat.CFrame = savedCF
        Window:Notify({Title = "HAVEN HUB", Description = "Invisibility enabled", Duration = 4})
      end
    end
  end)

  LocalPlayer.CharacterAdded:Connect(function()
    isInvis = false
    local chair = workspace:FindFirstChild("invischair")
    if chair then chair:Destroy() end
  end)

  shared.Player:Toggle("AntiFling", "Anti Fling", function(arg1)
    if arg1 then
      antifling = RunService.Stepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
          if p ~= LocalPlayer and p.Character then
            for _, d in pairs(p.Character:GetDescendants()) do
              if d:IsA("BasePart") and d.CanCollide and not Options.TargetFling:GetValue() then d.CanCollide = false end
            end
          end
        end
      end)
    end
    repeat task.wait() until not Options.AntiFling:GetValue()
    if antifling then antifling:Disconnect() end
  end)

  -- حماية التبادل (Anti-Stealer)
  local trade = ReplicatedStorage:WaitForChild("Trade")
  local declineRemote = trade:FindFirstChild("DeclineTrade")
  local dialogOpen = false
  local tradeConn
  if declineRemote and declineRemote:IsA("RemoteEvent") then
    declineRemote:FireServer()
    tradeConn = trade:WaitForChild("UpdateTrade").OnClientEvent:Connect(function()
      if declineRemote.Parent then declineRemote:FireServer() end
      if not dialogOpen then
        dialogOpen = true
        Window:Dialog({
          Title = "HAVEN HUB SECURITY",
          Description = "We detected an unauthorized trade in the background and blocked it automatically.",
          Buttons = {
            {Name = "Keep Protection Enabled", Callback = function() dialogOpen = false end},
            {Name = "Disable Protection", Callback = function() if tradeConn then tradeConn:Disconnect() tradeConn = nil end dialogOpen = false end}
          }
        })
      end
    end)
  end

  -- تتبع العملات والـ Webhook
  local coinCollected = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Gameplay"):FindFirstChild("CoinCollected")
  local tbl5, tbl6 = {}, {}
  local res36 = coinCollected.OnClientEvent:Connect(function(arg1, arg2)
    tbl5[arg1] = tbl5[arg1] or 0
    tbl6[arg1] = tbl6[arg1] or 0
    local diff = arg2 - tbl6[arg1]
    if diff > 0 then tbl5[arg1] = tbl5[arg1] + diff end
    tbl6[arg1] = arg2
  end)

  local function SendCoinWebhook(coinsGained, bagType)
    local now = os.date("!*t", os.time())
    pcall(function()
      local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
      local sec = Options.WebhookTimeInSeconds or 60
      local mins = sec / 60
      local mFmt = (mins % 1 == 0) and mins or tonumber(string.format("%.1f", mins))
      local str = tostring(mFmt) .. " " .. (mFmt == 1 and "Minute" or "Minutes")
      req({
        Url = WebhookInput:GetInput(),
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
          username = "Haven Hub - Coin Tracker",
          embeds = {{
            title = "Haven Hub Currency Tracker",
            color = 5814783,
            fields = {
              {name = "Bag:", value = tostring(bagType), inline = false},
              {name = "Coins Collected in " .. str .. ":", value = tostring(coinsGained), inline = false},
              {name = "Estimated Coins per Hour:", value = tostring(math.floor(coinsGained / sec * 3600)), inline = false}
            },
            timestamp = string.format("%d-%d-%dT%02d:%02d:%02dZ", now.year, now.month, now.day, now.hour, now.min, now.sec),
            footer = {text = "Powered by Haven Hub"}
          }}
        })
      })
    end)
  end

  task.spawn(function()
    while task.wait(0.5) do
      if shared.VertexLoaded ~= true then break end
      if not Options.CoinTracker:GetValue() then
        TrackerStatusLabel:UpdateName("COIN TRACKER IS TURNED OFF")
        table.clear(tbl5) table.clear(tbl6)
      else
        local cd = Options.WebhookTimeInSeconds or 60
        while cd > 0 and Options.CoinTracker:GetValue() do
          TrackerStatusLabel:UpdateName("WEBHOOK SENDING IN " .. cd .. " SECONDS")
          task.wait(1) cd = cd - 1
        end
        if Options.CoinTracker:GetValue() then
          TrackerStatusLabel:UpdateName("SENDING WEBHOOK...")
          for k, v in pairs(tbl5) do if v > 0 then SendCoinWebhook(v, k) end end
          TrackerStatusLabel:UpdateName("WEBHOOK SENT SUCCESSFULLY")
          table.clear(tbl5)
        end
      end
    end
  end)

  task.spawn(function()
    while task.wait(0.1) do
      if shared.VertexLoaded ~= true then break end
      pcall(function()
        v14 = FindPlayerWithTool("Knife")
        v15 = FindPlayerWithTool("Gun")
        roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
      end)
    end
    if unboxConnection then unboxConnection:Disconnect() end
    if res36 then res36:Disconnect() end
    if tradeConn then tradeConn:Disconnect() end
    if res12 then res12:Disconnect() end
    if res13 then res13:Disconnect() end
    shared.speed = nil
  end)

  Loader:Set(88)
  shared.tabs.Main:Select(shared.Main)
  shared.tabs.Settings:InsertConfigSection("Left", Window)
  HavenLib:LoadConfig(game.PlaceId)
  Loader:Finish()

  Window:Notify({
    Title = "HAVEN HUB LOADED",
    Description = "Welcome to Haven Hub. Press LeftControl or HH to toggle UI.",
    Duration = 6
  })

  -- حماية السقوط في الـ Void
  local fallenHeight = workspace.FallenPartsDestroyHeight
  while task.wait(0.1) do
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root then
      val = nil
    else
      local y = root.Position.Y
      if y < fallenHeight or y > 5000 then
        val = val or os.clock()
        if (os.clock() - val) >= 5 and v91 then
          root.CFrame = v91 + Vector3.new(0, 4, 0)
          root.AssemblyLinearVelocity = Vector3.zero
          root.AssemblyAngularVelocity = Vector3.zero
        end
      else
        val = nil
        if hum and hum.FloorMaterial ~= Enum.Material.Air then
          local params = RaycastParams.new()
          params.FilterType = Enum.RaycastFilterType.Exclude
          params.FilterDescendantsInstances = {char}
          local hit = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params)
          if hit and hit.Instance:IsA("BasePart") then v91 = root.CFrame end
        end
      end
    end
  end
end)()