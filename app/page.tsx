"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { useTheme } from "next-themes"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Music, Video, Newspaper, Users, ShoppingBag, Calendar } from "lucide-react"
import { cn } from "@/lib/utils"
import { SafeHeroVideoCarousel } from "@/components/safe-hero-video-carousel"
import { getOptimizedVideoSources } from "@/utils/video-utils"
import EriggaRadio from "@/components/erigga-radio"

export default function HomePage() {
  const { theme, resolvedTheme } = useTheme()
  const [currentSlide, setCurrentSlide] = useState(0)
  const [mounted, setMounted] = useState(false)
  const videoSources = getOptimizedVideoSources()
  const primaryVideoUrl =
    videoSources[0]?.src ||
    "/videoshttps://hebbkx1anhila5yf.public.blob.vercel-storage.com/git-blob/prj_87iLY6t51DXvy0yPJ00SYhwlKXWl/K6Q-Lit6vuzvhNfoGXuTFB/public/erigga-hero-video.mp4"

  // Hero images
  const heroImages = [
    "/images/hero/erigga1.jpeg",
    "/images/hero/erigga2.jpeg",
    "/images/hero/erigga3.jpeg",
    "/images/hero/erigga4.jpeg",
  ]

  // Features data
  const features = [
    {
      title: "Media Vault",
      description: "Access Erigga's complete discography, music videos, and exclusive content.",
      icon: Music,
      href: "/vault",
      color: "from-brand-lime to-brand-teal dark:from-white dark:to-harkonnen-gray",
    },
    {
      title: "Erigga Chronicles",
      description: "Follow Erigga's journey through animated stories and documentaries.",
      icon: Video,
      href: "/chronicles",
      color: "from-brand-teal to-brand-lime-dark dark:from-harkonnen-gray dark:to-white",
    },
    {
      title: "Community",
      description: "Connect with other fans, share content, and participate in discussions.",
      icon: Users,
      href: "/community",
      color: "from-brand-lime-dark to-brand-teal-light dark:from-white dark:to-harkonnen-light-gray",
    },
    {
      title: "Merch Store",
      description: "Shop exclusive Erigga merchandise and limited edition items.",
      icon: ShoppingBag,
      href: "/merch",
      color: "from-brand-teal-light to-brand-lime dark:from-harkonnen-light-gray dark:to-white",
    },
    {
      title: "Events & Tickets",
      description: "Get early access to concert tickets and exclusive events.",
      icon: Calendar,
      href: "/tickets",
      color: "from-brand-lime to-brand-teal-dark dark:from-white dark:to-harkonnen-dark-gray",
    },
    {
      title: "Premium Tiers",
      description: "Upgrade your experience with exclusive perks and content.",
      icon: Newspaper,
      href: "/premium",
      color: "from-brand-teal-dark to-brand-lime-light dark:from-harkonnen-dark-gray dark:to-white",
    },
  ]

  // Testimonials data
  const testimonials = [
    {
      quote: "Erigga's platform connects me directly with real fans. The community here is authentic.",
      author: "WarriKing23",
      tier: "Blood Brotherhood",
    },
    {
      quote: "The exclusive content in the vault is worth every coin. Can't get this anywhere else!",
      author: "PaperBoi99",
      tier: "Elder",
    },
    {
      quote: "Chronicles series tells Erigga's story in a way I've never seen before. Pure street wisdom.",
      author: "LagosHustler",
      tier: "Pioneer",
    },
  ]

  // Tier plans data
  const tierPlans = [
    {
      name: "Grassroot",
      price: "Free",
      description: "Basic access to the platform",
      features: ["Community access", "Public content", "Event announcements", "Basic profile"],
      color: "border-grassroot-primary dark:border-grassroot-primary",
      bgColor: "bg-grassroot-secondary/20 dark:bg-grassroot-secondary",
      href: "/signup",
    },
    {
      name: "Pioneer",
      price: "₦2,000",
      period: "monthly",
      description: "Enhanced access with exclusive content",
      features: [
        "All Grassroot features",
        "Early music releases",
        "Exclusive interviews",
        "Discounted merch",
        "Pioneer badge",
      ],
      color: "border-pioneer-primary dark:border-pioneer-primary",
      bgColor: "bg-pioneer-secondary/20 dark:bg-pioneer-secondary",
      href: "/premium",
      popular: true,
    },
    {
      name: "Elder",
      price: "₦5,000",
      period: "monthly",
      description: "Premium access with VIP benefits",
      features: [
        "All Pioneer features",
        "Behind-the-scenes content",
        "Studio session videos",
        "Priority event access",
        "Monthly Erigga coins",
        "Elder badge",
      ],
      color: "border-elder-primary dark:border-elder-primary",
      bgColor: "bg-elder-secondary/20 dark:bg-elder-secondary",
      href: "/premium",
    },
    {
      name: "Blood Brotherhood",
      price: "₦10,000",
      period: "monthly",
      description: "Ultimate fan experience",
      features: [
        "All Elder features",
        "Direct messaging with Erigga",
        "Virtual meet & greets",
        "Exclusive merchandise",
        "Blood Brotherhood badge",
        "Voting rights on new content",
      ],
      color: "border-blood-primary dark:border-blood-primary",
      bgColor: "bg-blood-secondary/20 dark:bg-blood-secondary",
      href: "/premium",
    },
  ]

  // Auto-advance carousel
  useEffect(() => {
    setMounted(true)
    const interval = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % heroImages.length)
    }, 5000)
    return () => clearInterval(interval)
  }, [heroImages.length])

  if (!mounted) {
    return null
  }

  return (
    <div className="flex flex-col min-h-screen">
      {/* Erigga Radio Widget - Only on home page */}
      <EriggaRadio />

      {/* Hero Section */}
      <section className="relative h-[80vh] w-full">
        <SafeHeroVideoCarousel images={heroImages} videoUrl={primaryVideoUrl} className="absolute inset-0" />

        <div className="absolute inset-0 flex items-center justify-center z-10">
          <div className="text-center max-w-3xl px-4">
            <h1 className="text-4xl md:text-6xl font-bold text-white mb-6 drop-shadow-lg">
              Welcome to the Official Erigga Live Platform
            </h1>
            <p className="text-xl md:text-2xl text-white/90 mb-8 drop-shadow-md">
              Join the community and get exclusive access to music, videos, and events
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/signup" className="inline-block">
                <div
                  className={cn(
                    "transition-all duration-300 font-bold rounded-lg py-3 px-8 text-center shadow-lg",
                    "transform hover:scale-105 hover:shadow-xl",
                    resolvedTheme === "dark"
                      ? "bg-white text-harkonnen-black hover:bg-gray-200"
                      : "bg-brand-lime text-brand-teal hover:bg-brand-lime-dark",
                  )}
                >
                  Join Now
                </div>
              </Link>
              <Link href="/vault" className="inline-block">
                <div
                  className={cn(
                    "transition-all duration-300 font-bold rounded-lg py-3 px-8 text-center shadow-lg",
                    "transform hover:scale-105 hover:shadow-xl",
                    resolvedTheme === "dark"
                      ? "bg-transparent border-2 border-white text-white hover:bg-white/10"
                      : "bg-brand-teal text-white hover:bg-brand-teal-dark",
                  )}
                >
                  Explore Content
                </div>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Rest of the home page content */}
      <section className="py-12 px-4 bg-gray-50 dark:bg-gray-900">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12 text-gray-900 dark:text-white">Explore the Platform</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <Card>
              <CardContent className="p-6">
                <h3 className="text-xl font-bold mb-2">Media Vault</h3>
                <p className="text-gray-600 dark:text-gray-400 mb-4">
                  Access exclusive music, videos, and behind-the-scenes content
                </p>
                <Button asChild variant="outline">
                  <Link href="/vault">Explore Vault</Link>
                </Button>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6">
                <h3 className="text-xl font-bold mb-2">Community</h3>
                <p className="text-gray-600 dark:text-gray-400 mb-4">
                  Connect with others, share content, and join discussions
                </p>
                <Button asChild variant="outline">
                  <Link href="/community">Join Community</Link>
                </Button>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6">
                <h3 className="text-xl font-bold mb-2">Chronicles</h3>
                <p className="text-gray-600 dark:text-gray-400 mb-4">
                  Follow Erigga's journey through exclusive stories and updates
                </p>
                <Button asChild variant="outline">
                  <Link href="/chronicles">Read Chronicles</Link>
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-background">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Platform Features</h2>
            <p className="text-muted-foreground max-w-2xl mx-auto">
              Everything you need to connect with Erigga and fellow fans in one place.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature, index) => (
              <Link key={index} href={feature.href}>
                <Card
                  className={cn(
                    "h-full transition-all duration-300 hover:scale-105 overflow-hidden",
                    resolvedTheme === "dark" ? "harkonnen-card" : "border border-gray-200",
                  )}
                >
                  <CardContent className="p-6 flex flex-col h-full">
                    <div
                      className={cn(
                        "w-12 h-12 rounded-full mb-4 flex items-center justify-center bg-gradient-to-br",
                        feature.color,
                      )}
                    >
                      <feature.icon className={cn("h-6 w-6", resolvedTheme === "dark" ? "text-black" : "text-white")} />
                    </div>
                    <h3 className="text-xl font-bold mb-2">{feature.title}</h3>
                    <p className="text-muted-foreground flex-grow">{feature.description}</p>
                    <div className="mt-4 flex items-center text-sm font-medium text-brand-teal dark:text-white">
                      Learn more
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-4 w-4 ml-1"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                      </svg>
                    </div>
                  </CardContent>
                </Card>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="py-20 bg-accent">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Fan Testimonials</h2>
            <p className="text-muted-foreground max-w-2xl mx-auto">
              Hear what the community has to say about the Erigga fan platform.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {testimonials.map((testimonial, index) => (
              <Card
                key={index}
                className={cn("h-full", resolvedTheme === "dark" ? "harkonnen-card" : "border border-gray-200")}
              >
                <CardContent className="p-6 flex flex-col h-full">
                  <div className="mb-4">
                    {[...Array(5)].map((_, i) => (
                      <svg
                        key={i}
                        className="inline-block w-5 h-5 text-yellow-500"
                        fill="currentColor"
                        viewBox="0 0 20 20"
                      >
                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                      </svg>
                    ))}
                  </div>
                  <p className="text-lg italic mb-6 flex-grow">"{testimonial.quote}"</p>
                  <div>
                    <p className="font-bold">{testimonial.author}</p>
                    <p className="text-sm text-muted-foreground">{testimonial.tier} Member</p>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing Section */}
      <section className="py-20 bg-background">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Membership Tiers</h2>
            <p className="text-muted-foreground max-w-2xl mx-auto">
              Choose the tier that fits your level of fandom and unlock exclusive perks.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {tierPlans.map((plan, index) => (
              <div key={index} className="relative">
                {plan.popular && (
                  <div className="absolute -top-4 left-0 right-0 flex justify-center">
                    <span className="bg-brand-lime text-brand-teal dark:bg-white dark:text-black px-3 py-1 rounded-full text-sm font-medium">
                      Most Popular
                    </span>
                  </div>
                )}
                <Card
                  className={cn(
                    "h-full border-2 transition-all duration-300",
                    plan.color,
                    plan.popular ? "transform scale-105" : "",
                    resolvedTheme === "dark" ? "harkonnen-card" : "",
                  )}
                >
                  <CardContent className={cn("p-6", plan.bgColor)}>
                    <h3 className="text-xl font-bold mb-1">{plan.name}</h3>
                    <div className="mb-4">
                      <span className="text-3xl font-bold">{plan.price}</span>
                      {plan.period && <span className="text-muted-foreground">/{plan.period}</span>}
                    </div>
                    <p className="text-muted-foreground mb-6">{plan.description}</p>
                    <ul className="space-y-2 mb-6">
                      {plan.features.map((feature, i) => (
                        <li key={i} className="flex items-start">
                          <svg
                            className="h-5 w-5 text-green-500 mr-2 mt-0.5"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M5 13l4 4L19 7"
                            ></path>
                          </svg>
                          <span>{feature}</span>
                        </li>
                      ))}
                    </ul>
                    <Button
                      className={cn(
                        "w-full",
                        plan.name === "Grassroot"
                          ? "bg-grassroot-primary text-white hover:bg-opacity-90"
                          : plan.name === "Pioneer"
                            ? "bg-pioneer-primary text-white hover:bg-opacity-90"
                            : plan.name === "Elder"
                              ? "bg-elder-primary text-white hover:bg-opacity-90"
                              : "bg-blood-primary text-white hover:bg-opacity-90",
                      )}
                      asChild
                    >
                      <Link href={plan.href}>{plan.name === "Grassroot" ? "Sign Up Free" : "Subscribe Now"}</Link>
                    </Button>
                  </CardContent>
                </Card>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-brand-teal dark:bg-harkonnen-black text-white">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-6">Ready to Join the Movement?</h2>
          <p className="text-lg max-w-2xl mx-auto mb-8 text-white/80">
            Get access to exclusive content, connect with other fans, and be part of Erigga's journey.
          </p>
          <Link href="/signup" className="inline-block">
            <div
              className={cn(
                "transition-all duration-300 font-bold rounded-lg py-3 px-8 text-center shadow-lg",
                "transform hover:scale-105 hover:shadow-xl",
                resolvedTheme === "dark"
                  ? "bg-white text-harkonnen-black hover:bg-gray-200"
                  : "bg-brand-lime text-brand-teal hover:bg-brand-lime-dark",
              )}
            >
              Join Now
            </div>
          </Link>
        </div>
      </section>
    </div>
  )
}
